fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'liquid_stations'
author 'Liquid Stations'
description 'Universal liquid management stations with persistence, weather sync, and decay for ESX + ox stack'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/liquids.lua',
    'shared/water_sources.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/config_server.lua',
    'server/main.lua'
}

dependencies {
    'ox_lib',
    'ox_target',
    'ox_inventory',
    'es_extended',
    'oxmysql'
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/app.js'
}
