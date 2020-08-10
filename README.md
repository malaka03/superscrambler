# SuperScrambler - Event name scrambler for FiveM

This resource will automatically scramble all your event names so that your server is more secure from injectors and other cheaters alike.  
It currently only supports Lua->Lua events. Any cross-runtime events will not work properly and have to be added to the whitelist in `main.lua`!

## How to set up
1. Clone this repository into your `server-data/resources` folder.
2. Add `ensure superscrambler` above all other `ensure` or `start` commands in your `server.cfg` - **VERY IMPORTANT**.
3. Add `shared_script '@superscrambler/main.lua'` to the top of **every** Lua resource's `__resource.lua` or `fxmanifest.lua`. It should look something like this:
```
fx_version 'bodacious'
game 'gta5'
shared_script '@superscrambler/main.lua'

server_script 'your_other_scripts.lua'
...
```
4. Restart your server.

Note: you should add it to the stock server resources like 'chat', 'spawnmanager', etc. as well! **Any resources that use a Lua script with events!!**

--
# To do:
- Make it work across runtimes (currently only Lua is supported)
