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
