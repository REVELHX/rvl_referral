fx_version 'cerulean'
lua54 'yes'
game 'gta5'

description "Made by REVEL"

version '1.0'

client_scripts { 
	'client.lua',
}

server_scripts { 
	'@mysql-async/lib/MySQL.lua',
	'server.lua',
}

shared_script 'config.lua'




ui_page 'ui/index.html'

files {
    'ui/*.js',
	'ui/*.html',
	'ui/*.css'
}