Config = {}
Config.Interaction = nil
Config.Theme = 'cyberpunk'
Config.Debug = false
Config.Locale = 'en'

Config.TANK_LIMIT_PER_PLAYER = 3
Config.PROGRESS_INSTALL = 5000
Config.ENABLE_DUI = true
Config.BoilDurationMs = 8000
Config.BurnRatePerLiter = 0.05 -- fuel items per liter (rounded up), e.g. 20L => 1 item

Config.BurnableItems = {
    coal = { remove = 1 },
    charcoal = { remove = 1 },
}

Config.DELETE_OLD_DAYS = 10
Config.DELETE_OPTIONS = { DeleteOnlyIfEmpty = true, DeleteOnlyIfBroken = false }
Config.DecayTickMs = 60000
Config.WeatherTickMs = 60000
Config.InteractionDistance = 2.5

Config.EnableRainCollection = true
Config.RainyFillableTypes = { 'dirty_water' }
Config.RainWeatherStates = { RAIN = true, THUNDER = true, CLEARING = true }

Config.LiquidTypes = {
    dirty_water = { label = 'Dirty Water', color = '#5d7f99' },
    water = { label = 'Clean Water', color = '#3498db' },
    fuel = { label = 'Fuel', color = '#f39c12' },
}

-- 2 different props/configs
Config.Containers = {
    boiler_tank = { prop = 'prop_oldlight_01b', item = 'boiler_tank', capacity = 120.0, maxHealth = 180.0, decayRate = 0.7, type = 'dirty_water', interactionDistance = 2.5, rainFillAmount = 0.20, canBoil = true, uiType = 'boiler' },
    storage_tank = { prop = 'prop_barrel_03d', item = 'storage_tank', capacity = 250.0, maxHealth = 260.0, decayRate = 0.4, type = 'water', interactionDistance = 2.8, rainFillAmount = 0.0, canBoil = false, uiType = 'storage' },
}

Config.CollectItems = {
    water = { bottle_water = { amount = 1, add = 0.5, give = 'empty_waterbottle' }, jug_water = { amount = 1, add = 1.0, give = 'jug_empty' } },
    dirty_water = { dirty_waterbottle = { amount = 1, add = 0.5, give = 'empty_waterbottle' }, jug_dirtywater = { amount = 1, add = 1.0, give = 'jug_empty' } }
}

Config.FillItems = {
    water = { empty_waterbottle = { remove = 1, take = 0.5, give = 'bottle_water' }, jug_empty = { remove = 1, take = 1.0, give = 'jug_water' } },
    dirty_water = { empty_waterbottle = { remove = 1, take = 0.5, give = 'dirty_waterbottle' }, jug_empty = { remove = 1, take = 1.0, give = 'jug_dirtywater' } }
}

Config.FixedTanks = {
    { id = 'boiler_fixed_1', tankType = 'boiler_tank', coords = vec3(-1414.2345, 5098.0386, 59.5271), heading = 90.0 },
    { id = 'storage_fixed_1', tankType = 'storage_tank', coords = vec3(-1410.0, 5098.0, 59.5271), heading = 90.0 }
}
