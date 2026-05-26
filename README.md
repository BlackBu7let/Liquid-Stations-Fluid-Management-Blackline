# Liquid Stations (ESX + ox)

## What this build includes
- Auto table creation on first server start (`bl_water_stations`).
- Placeable tanks with persistence, decay, weather refill, and fixed stations.
- Configurable liquid/container/item conversion setup.

## Database
No manual SQL import is required. The table is created automatically on first start:
- `bl_water_stations` — stores tank positions, owner, liquid amount/type, health, fixed flag, and timestamps.

## Item registration
Register the items from `_INSTALL/ox_items.txt` in your inventory:
- `small_water_tank`, `medium_water_tank`, `large_water_tank`
- `bottle_empty`, `jug_empty`, `bucket_empty`
- `bottle_water`, `jug_water`, `bucket_water`
- `bottle_fuel`, `jug_fuel`, `bucket_fuel`
- `steel`

Copy images from `_INSTALL/images/` into your inventory image folder.

## Install
1. Ensure dependencies: `ox_lib`, `ox_target`, `ox_inventory`, `oxmysql`, `es_extended`
2. Add this resource after dependencies:
   ```cfg
   ensure liquid_stations
   ```

## Command
- `/placeliquidstation [small_tank|medium_tank|large_tank]`


## Water source collection
- Added GTA5 map water-source zones (beach/lake/river examples).
- Use **empty bottle** at source via ox_target: `Collect Water (Empty Bottle)`.
- Event converts `bottle_empty` -> `bottle_water`.


## Dirty -> Clean water gameplay
- Collecting at map water source now uses `empty_waterbottle` and gives `dirty_waterbottle`.
- You can also fill `jug_empty` with dirty water in tanks (to `jug_dirtywater`).
- Use tank UI button **BOIL TO CLEAN WATER** to convert tank liquid type from `dirty_water` to `water`.
- After boiling, fill outputs become clean: `bottle_water` / `jug_water`.


## Boiler + Storage split
- Added **2 different props/configs**: `boiler_tank` and `storage_tank`.
- Added **2 different UIs** in NUI: Boiler UI (with boil button) and Storage UI (no boil).
- Place with `/placeliquidstation [boiler_tank|storage_tank]`.


## Boiling fuel requirement
- Boiling dirty water now requires 1 configured burnable item.
- Default allowed fuel items: `coal` or `charcoal` (configured in `Config.BurnableItems`).
- You can add/remove burnable items in config and set per-item consume amounts.


## Burn rate per liter (Config)
- Added `Config.BurnRatePerLiter` to scale boil fuel cost with tank liters.
- Formula: `requiredFuel = ceil(currentLiters * BurnRatePerLiter)` (minimum 1).
- Example with default `0.05`: 20L requires 1 fuel item, 100L requires 5.


## Drag & Drop + Drain + No Mix
- UI now supports drag-and-drop tiles into a drop zone (click still works).
- Boiling auto-consumes configured burn materials from ox_inventory (no manual fuel slot needed).
- Liquids cannot be mixed because tank actions are resolved only against the current tank liquid type mappings.
- Added drain button for boiler and storage to remove `Config.DrainPerAction` liters per action.
