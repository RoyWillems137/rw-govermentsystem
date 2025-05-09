fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'RW Scripts'

shared_scripts {
	'@es_extended/locale.lua',
	'locales/nl.lua',
	'locales/en.lua',
	'config.lua',
	'@ox_lib/init.lua',
	
}

server_scripts {
	'@es_extended/locale.lua',
	'locales/nl.lua',
	'locales/en.lua',
	'config.lua',
	'server/server.lua',
	'@oxmysql/lib/MySQL.lua',
}

client_scripts {
	'@es_extended/locale.lua',
	'locales/nl.lua',
	'locales/en.lua',
	'config.lua',
	'client/client.lua',
}

files {
	'locales/nl.lua',
	'locales/en.lua',
}