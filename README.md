# Simple GLua Error Logger

Adds a simple script to capture and save Lua errors from your server.

**Requires [gm_luaerror](https://github.com/danielga/gm_luaerror) module to work. The script will simply error if this module is missing. Only the server needs to have the module installed.**

You can find all the captured errors inside the `garrysmod/data/error_logs/` folder. The structure used to save these logs will be `error_logs/YYYY-MM-DD/addon-name/realm-name.txt` for easier addon error debugging. Inside of these files, you'll find a list of errors and the amount of times they've been detected during the day.
