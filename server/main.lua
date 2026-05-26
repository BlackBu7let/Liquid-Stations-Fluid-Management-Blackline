local ESX = exports['es_extended']:getSharedObject()

local Tanks = {}
local PlacementCounter = {}

local function nowUnix() return os.time() end
local function clamp(v, a, b) if v < a then return a elseif v > b then return b else return v end end

local function ensureTable()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `bl_water_stations` (
          `id` varchar(128) NOT NULL,
          `owner` varchar(80) NOT NULL,
          `tank_type` varchar(60) NOT NULL,
          `x` double NOT NULL,
          `y` double NOT NULL,
          `z` double NOT NULL,
          `heading` float NOT NULL,
          `health` float NOT NULL DEFAULT 100,
          `liquid_type` varchar(40) NOT NULL DEFAULT 'water',
          `amount` float NOT NULL DEFAULT 0,
          `is_fixed` tinyint(1) NOT NULL DEFAULT 0,
          `updated_at` bigint NOT NULL DEFAULT 0,
          PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]])
end

local function canRainFill(liquidType)
    for _, v in ipairs(Config.RainyFillableTypes or {}) do if v == liquidType then return true end end
    return false
end

local function persistTank(t)
    MySQL.update.await([[INSERT INTO bl_water_stations (id, owner, tank_type, x,y,z,heading,health,liquid_type,amount,is_fixed,updated_at)
    VALUES (?,?,?,?,?,?,?,?,?,?,?,?)
    ON DUPLICATE KEY UPDATE owner=VALUES(owner),tank_type=VALUES(tank_type),x=VALUES(x),y=VALUES(y),z=VALUES(z),heading=VALUES(heading),health=VALUES(health),liquid_type=VALUES(liquid_type),amount=VALUES(amount),is_fixed=VALUES(is_fixed),updated_at=VALUES(updated_at)]], {
        t.id, t.owner, t.tankType, t.coords.x, t.coords.y, t.coords.z, t.heading, t.health, t.liquidType, t.amount, t.fixed and 1 or 0, nowUnix()
    })
end

local function broadcast() TriggerClientEvent('liquid_stations:client:syncStations', -1, Tanks) end

local function loadAll()
    local rows = MySQL.query.await('SELECT * FROM bl_water_stations') or {}
    Tanks = {}
    for _, r in ipairs(rows) do
        Tanks[r.id] = {
            id = r.id, owner = r.owner, tankType = r.tank_type, coords = vec3(r.x, r.y, r.z), heading = r.heading,
            health = r.health, liquidType = r.liquid_type or 'water', amount = tonumber(r.amount) or 0.0,
            updatedAt = r.updated_at or nowUnix(), fixed = (r.is_fixed == 1)
        }
    end
    for _, f in ipairs(Config.FixedTanks or {}) do
        if not Tanks[f.id] then
            local c = Config.Containers[f.tankType]
            if c then
                Tanks[f.id] = { id = f.id, owner = 'SYSTEM', tankType = f.tankType, coords = f.coords, heading = f.heading or 0.0, health = c.maxHealth, liquidType = c.type, amount = 0.0, updatedAt = nowUnix(), fixed = true }
                persistTank(Tanks[f.id])
            end
        end
    end
end

lib.callback.register('liquid_stations:server:placeStation', function(source, tankType)
    local xPlayer = ESX.GetPlayerFromId(source); if not xPlayer then return { ok = false, err = 'invalid_player' } end
    local cfg = Config.Containers[tankType]; if not cfg then return { ok = false, err = 'invalid_type' } end
    PlacementCounter[xPlayer.identifier] = (PlacementCounter[xPlayer.identifier] or 0)
    if PlacementCounter[xPlayer.identifier] >= Config.TANK_LIMIT_PER_PLAYER then return { ok = false, err = 'limit' } end
    local itemCount = exports.ox_inventory:GetItem(source, cfg.item, nil, true) or 0
    if itemCount < 1 then return { ok = false, err = 'missing_item' } end

    exports.ox_inventory:RemoveItem(source, cfg.item, 1)
    local ped = GetPlayerPed(source); local p = GetEntityCoords(ped)
    local id = ('%s_%s_%s'):format(xPlayer.identifier, tankType, nowUnix())
    Tanks[id] = { id = id, owner = xPlayer.identifier, tankType = tankType, coords = vec3(p.x, p.y, p.z), heading = GetEntityHeading(ped), health = cfg.maxHealth, liquidType = cfg.type, amount = 0.0, updatedAt = nowUnix(), fixed = false }
    PlacementCounter[xPlayer.identifier] = PlacementCounter[xPlayer.identifier] + 1
    persistTank(Tanks[id]); broadcast(); return { ok = true, id = id }
end)

RegisterNetEvent('liquid_stations:server:transferLiquid', function(id, amount, mode)
    local t = Tanks[id]; if not t then return end
    local cfg = Config.Containers[t.tankType]; if not cfg then return end
    amount = tonumber(amount) or 0; if amount <= 0 then return end
    if mode == 'deposit' then t.amount = clamp(t.amount + amount, 0.0, cfg.capacity) end
    if mode == 'withdraw' then t.amount = clamp(t.amount - amount, 0.0, cfg.capacity) end
    t.updatedAt = nowUnix(); persistTank(t); broadcast()
end)


RegisterNetEvent('liquid_stations:server:itemAction', function(id, item, mode)
    local src = source
    local t = Tanks[id]; if not t then return end
    local cfg = Config.Containers[t.tankType]; if not cfg then return end

    if mode == 'fill' then
        local map = (Config.FillItems[t.liquidType] or {})[item]
        if not map then return end
        if (exports.ox_inventory:GetItem(src, item, nil, true) or 0) < (map.remove or 1) then return end
        exports.ox_inventory:RemoveItem(src, item, map.remove or 1)
        exports.ox_inventory:AddItem(src, map.give, 1)
        t.amount = clamp(t.amount + (map.take or 0), 0.0, cfg.capacity)
    elseif mode == 'collect' then
        local map = (Config.CollectItems[t.liquidType] or {})[item]
        if not map then return end
        if t.amount < (map.add or 0) then return end
        if (exports.ox_inventory:GetItem(src, map.give, nil, true) or 0) < 1 then return end
        exports.ox_inventory:RemoveItem(src, map.give, 1)
        exports.ox_inventory:AddItem(src, item, map.amount or 1)
        t.amount = clamp(t.amount - (map.add or 0), 0.0, cfg.capacity)
    else
        return
    end

    t.updatedAt = nowUnix(); persistTank(t); broadcast()
end)

RegisterNetEvent('liquid_stations:server:dismantleTank', function(id)
    local src = source
    local t = Tanks[id]; if not t or t.fixed then return end
    local xPlayer = ESX.GetPlayerFromId(src); if not xPlayer or xPlayer.identifier ~= t.owner then return end
    local item = Config.Containers[t.tankType] and Config.Containers[t.tankType].item
    if item then exports.ox_inventory:AddItem(src, item, 1) end
    Tanks[id] = nil
    MySQL.update.await('DELETE FROM bl_water_stations WHERE id = ?', { id })
    broadcast()
end)


RegisterNetEvent('liquid_stations:server:collectFromSource', function(sourceId)
    local src = source
    local sourceCfg
    for _, ws in ipairs(WaterSources or {}) do
        if ws.id == sourceId then sourceCfg = ws break end
    end
    if not sourceCfg then return end

    local ped = GetPlayerPed(src)
    local p = GetEntityCoords(ped)
    local dist = #(p - sourceCfg.coords)
    if dist > (sourceCfg.radius + 2.0) then return end

    local rule = (Config.FillItems.dirty_water or {}).empty_waterbottle
    if not rule then return end
    local has = exports.ox_inventory:GetItem(src, 'empty_waterbottle', nil, true) or 0
    if has < (rule.remove or 1) then return end

    exports.ox_inventory:RemoveItem(src, 'empty_waterbottle', rule.remove or 1)
    exports.ox_inventory:AddItem(src, rule.give or 'dirty_waterbottle', 1)
    TriggerClientEvent('ox_lib:notify', src, {title='Water Source', description='Collected water bottle', type='success'})
end)


RegisterNetEvent('liquid_stations:server:boilTankWater', function(id)
    local src = source
    local t = Tanks[id]; if not t then return end
    if t.liquidType ~= 'dirty_water' then return end
    local xPlayer = ESX.GetPlayerFromId(src); if not xPlayer then return end

    local burnedItem = nil
    for item, rules in pairs(Config.BurnableItems or {}) do
        local need = (rules and rules.remove) or 1
        if (exports.ox_inventory:GetItem(src, item, nil, true) or 0) >= need then
            burnedItem = item
            exports.ox_inventory:RemoveItem(src, item, need)
            break
        end
    end

    if not burnedItem then
        TriggerClientEvent('ox_lib:notify', src, { title = 'Tank System', description = 'Need burnable item: coal or charcoal', type = 'error' })
        return
    end

    t.liquidType = 'water'
    t.updatedAt = nowUnix()
    persistTank(t)
    broadcast()
    TriggerClientEvent('ox_lib:notify', src, { title = 'Tank System', description = ('Water boiled with %s'):format(burnedItem), type = 'success' })
end)

CreateThread(function()
    ensureTable()
    loadAll(); broadcast()
    while true do
        Wait(Config.DecayTickMs)
        local cutoff = Config.DELETE_OLD_DAYS and (nowUnix() - (Config.DELETE_OLD_DAYS * 86400)) or nil
        for id, t in pairs(Tanks) do
            local cfg = Config.Containers[t.tankType]
            if cfg then
                t.health = clamp(t.health - cfg.decayRate, 0.0, cfg.maxHealth)
                local previousUpdate = t.updatedAt or 0
                t.updatedAt = nowUnix()
                local del = false
                if cutoff and not t.fixed and (previousUpdate < cutoff) then
                    del = true
                    if Config.DELETE_OPTIONS.DeleteOnlyIfEmpty and t.amount > 0.0 then del = false end
                    if Config.DELETE_OPTIONS.DeleteOnlyIfBroken and t.health > 0.0 then del = false end
                end
                if del then
                    Tanks[id] = nil
                    MySQL.update.await('DELETE FROM bl_water_stations WHERE id = ?', { id })
                else
                    persistTank(t)
                end
            end
        end
        broadcast()
    end
end)

CreateThread(function()
    while true do
        Wait(Config.WeatherTickMs)
        if not Config.EnableRainCollection then goto continue end
        local weather = tostring(GetConvar('weather', 'CLEAR')):upper()
        if not Config.RainWeatherStates[weather] then goto continue end
        for _, t in pairs(Tanks) do
            local cfg = Config.Containers[t.tankType]
            if cfg and canRainFill(t.liquidType) then
                t.amount = clamp(t.amount + (cfg.rainFillAmount or 0.0), 0.0, cfg.capacity)
                persistTank(t)
            end
        end
        broadcast()
        ::continue::
    end
end)
