Config = {}
Config.Interaction = nil
Config.Theme = 'cyberpunk'
Config.Debug = false
Config.Locale = 'en'

Config.TANK_LIMIT_PER_PLAYER = 3
Config.PROGRESS_INSTALL = 5000
Config.ENABLE_DUI = true

Config.DELETE_OLD_DAYS = 10
Config.DELETE_OPTIONS = { DeleteOnlyIfEmpty = true, DeleteOnlyIfBroken = false }

Config.DecayTickMs = 60000
Config.WeatherTickMs = 60000
Config.InteractionDistance = 2.5

Config.EnableRainCollection = true
Config.RainyFillableTypes = { 'dirty_water' }
Config.RainWeatherStates = { RAIN = true, THUNDER = true, CLEARING = true }

Config.BoilDurationMs = 8000

Config.LiquidTypes = {
    dirty_water = { label = 'Dirty Water', color = '#5d7f99', colorDark = '#435d73', viscosity = 0.35, waveSpeed = 0.9, waveAmp = 5, bubbles = 6, shimmer = false, transparency = 0.88 },
    water = { label = 'Clean Water', color = '#3498db', colorDark = '#2980b9', viscosity = 0.3, waveSpeed = 1.0, waveAmp = 5, bubbles = 8, shimmer = false, transparency = 0.85 },
    fuel = { label = 'Fuel', color = '#f39c12', colorDark = '#d68910', viscosity = 0.6, waveSpeed = 0.7, waveAmp = 3, bubbles = 2, shimmer = true, transparency = 0.92 },
}

Config.Containers = {
    small_tank = { prop = 'prop_air_watertank3', item = 'small_water_tank', capacity = 50.0, maxHealth = 100.0, decayRate = 0.5, type = 'dirty_water', interactionDistance = 2.5, spawnDistance = 30.0, duiDistance = 8.0, duiScale = 0.04, duiOffset = vec3(0.0, 0.0, -1.0), rainFillAmount = 0.15, repairItems = { steel = { addHealth = 50.0 } } },
    medium_tank = { prop = 'prop_barrel_02a', item = 'medium_water_tank', capacity = 120.0, maxHealth = 160.0, decayRate = 0.8, type = 'dirty_water', interactionDistance = 2.5, spawnDistance = 35.0, duiDistance = 10.0, duiScale = 0.05, duiOffset = vec3(0.0, 0.0, 0.0), rainFillAmount = 0.25, repairItems = { steel = { addHealth = 40.0 } } },
    large_tank = { prop = 'prop_barrel_03d', item = 'large_water_tank', capacity = 200.0, maxHealth = 250.0, decayRate = 1.0, type = 'dirty_water', interactionDistance = 2.8, spawnDistance = 45.0, duiDistance = 12.0, duiScale = 0.06, duiOffset = vec3(0.0, 0.0, 0.2), rainFillAmount = 0.35, repairItems = { steel = { addHealth = 40.0 } } },
}

Config.CollectItems = {
    water = {
        bottle_water = { amount = 1, add = 0.5, give = 'empty_waterbottle' },
        jug_water = { amount = 1, add = 1.0, give = 'jug_empty' }
    },
    dirty_water = {
        dirty_waterbottle = { amount = 1, add = 0.5, give = 'empty_waterbottle' },
        jug_dirtywater = { amount = 1, add = 1.0, give = 'jug_empty' }
    },
    fuel = {
        bottle_fuel = { amount = 1, add = 0.5, give = 'empty_waterbottle' },
        jug_fuel = { amount = 1, add = 1.0, give = 'jug_empty' }
    }
}

Config.FillItems = {
    water = {
        empty_waterbottle = { remove = 1, take = 0.5, give = 'bottle_water' },
        jug_empty = { remove = 1, take = 1.0, give = 'jug_water' }
    },
    dirty_water = {
        empty_waterbottle = { remove = 1, take = 0.5, give = 'dirty_waterbottle' },
        jug_empty = { remove = 1, take = 1.0, give = 'jug_dirtywater' }
    },
    fuel = {
        empty_waterbottle = { remove = 1, take = 0.5, give = 'bottle_fuel' },
        jug_empty = { remove = 1, take = 1.0, give = 'jug_fuel' }
    }
}

Config.FixedTanks = {
    { id = 'sandy_shores_farm', tankType = 'large_tank', coords = vec3(-1414.2345, 5098.0386, 59.5271), heading = 90.0 }
}
