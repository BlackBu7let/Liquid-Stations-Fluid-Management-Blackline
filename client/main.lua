local Spawned, TankCache = {}, {}
local ActiveTankId = nil

local function closeUi()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    ActiveTankId = nil
end

local function cleanup()
    for _, d in pairs(Spawned) do if d.entity and DoesEntityExist(d.entity) then DeleteEntity(d.entity) end end
    Spawned = {}
end

local function getRelevantItems(liquidType)
    local out = {}
    local fill = Config.FillItems[liquidType] or {}
    local collect = Config.CollectItems[liquidType] or {}
    for item, def in pairs(fill) do
        out[#out+1] = { name = item, label = item, mode = 'fill', amountText = ('+%.1fL'):format(def.take or 0) }
    end
    for item, def in pairs(collect) do
        out[#out+1] = { name = item, label = item, mode = 'collect', amountText = ('-%.1fL'):format(def.add or 0) }
    end
    return out
end

local function openTankUI(id)
    local tank = TankCache[id]; if not tank then return end
    local cfg = Config.Containers[tank.tankType]; if not cfg then return end
    ActiveTankId = id
    SetNuiFocus(true, true)
    SendNUIMessage({
        action='open', tankId=id, amount=tank.amount or 0.0, capacity=cfg.capacity or 1.0,
        healthPct=((tank.health or 0) / (cfg.maxHealth or 100))*100, liquidType=tank.liquidType, items=getRelevantItems(tank.liquidType)
    })
end

RegisterNUICallback('close', function(_, cb) closeUi(); cb({ok=true}) end)
RegisterNUICallback('dismantle', function(data, cb)
    if data and data.tankId then TriggerServerEvent('liquid_stations:server:dismantleTank', data.tankId) end
    closeUi(); cb({ok=true})
end)
RegisterNUICallback('boil', function(data, cb)
    if data and data.tankId then
        if lib.progressCircle({duration = Config.BoilDurationMs or 8000, label='Boiling dirty water...'}) then
            TriggerServerEvent('liquid_stations:server:boilTankWater', data.tankId)
        end
    end
    cb({ok=true})
end)

RegisterNUICallback('itemAction', function(data, cb)
    if data and data.tankId and data.item and data.mode then
        TriggerServerEvent('liquid_stations:server:itemAction', data.tankId, data.item, data.mode)
    end
    cb({ok=true})
end)

RegisterNetEvent('liquid_stations:client:syncStations', function(tanks)
    TankCache = tanks or {}
    cleanup()
    for id, tank in pairs(TankCache) do
        local cfg = Config.Containers[tank.tankType]
        if cfg then
            local model = joaat(cfg.prop); RequestModel(model); while not HasModelLoaded(model) do Wait(0) end
            local entity = CreateObject(model, tank.coords.x, tank.coords.y, tank.coords.z - 1.0, false, false, false)
            SetEntityHeading(entity, tank.heading or 0.0); FreezeEntityPosition(entity, true)
            exports.ox_target:addLocalEntity(entity, {{ label='Open tank', distance=cfg.interactionDistance or Config.InteractionDistance, onSelect=function() openTankUI(id) end }})
            Spawned[id] = { entity=entity }
        end
    end
end)

CreateThread(function()
    for _, ws in ipairs(WaterSources or {}) do
        exports.ox_target:addSphereZone({
            coords = ws.coords,
            radius = ws.radius,
            debug = Config.Debug,
            options = {
                {
                    name = ('water_source_%s'):format(ws.id),
                    label = 'Collect Water (Empty Bottle)',
                    icon = 'fa-solid fa-bottle-water',
                    onSelect = function()
                        TriggerServerEvent('liquid_stations:server:collectFromSource', ws.id)
                    end
                }
            }
        })
    end
end)

RegisterCommand('placeliquidstation', function(_, args)
    local tankType = args[1] or 'small_tank'
    if not lib.progressCircle({duration = Config.PROGRESS_INSTALL, label='Installing tank...'}) then return end
    lib.callback('liquid_stations:server:placeStation', false, function(res)
        if not res or not res.ok then return lib.notify({title='Liquid Stations', description=(res and res.err) or 'error', type='error'}) end
        lib.notify({title='Liquid Stations', description='Tank installed', type='success'})
    end, tankType)
end)
