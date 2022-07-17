require("luaerror")

-- Enabling everything
luaerror.EnableRuntimeDetour(true)
luaerror.EnableCompiletimeDetour(true)
luaerror.EnableClientDetour(true)

local file        = file
local os          = os
local string      = string
local ErrorLog    = {}
local FilePattern = "^addons/(.-)/"
local FolderPath  = "error_logs/%s/%s"
local FilePath    = FolderPath .. "/%s.txt"
local ErrorText   = "Times detected: %s time(s)\n%s\n\n"
local Identifier  = "Simple GLua Error Logger"
local CurrentDate, QueueSave

-- Recursively gets or creates tables based on the provided arguments.
local function GetTable(...)
	local Result = ErrorLog
	local Keys   = { ... }

	for _, Key in ipairs(Keys) do
		local Value = Result[Key]

		if not Value then
			Value = {}

			Result[Key] = Value
		end

		Result = Value
	end

	return Result
end

-- Turns a table of errors into a neat list string.
local function GetErrorList(Errors)
	local List = ""

	for Error, Count in pairs(Errors) do
		List = List .. ErrorText:format(Count, Error)
	end

	return List
end

-- Saves the list of errors into a text file.
local function SaveContents(Date, Addon, Realm, Contents)
	local Folder = FolderPath:format(Date, Addon)
	local Path   = FilePath:format(Date, Addon, Realm)

	if not file.Exists(Folder, "DATA") then
		file.CreateDir(Folder)
	end

	file.Write(Path, Contents)
end

-- Saves all errors from the error log and cleans it if the day has changed
local function SaveErrors()
	for Addon, Realms in pairs(ErrorLog) do
		for Realm, Errors in pairs(Realms) do
			local Contents = GetErrorList(Errors)

			SaveContents(CurrentDate, Addon, Realm, Contents)
		end
	end

	local Date = os.date("%Y-%m-%d")

	if Date ~= CurrentDate then
		-- New day, new errors
		for K in pairs(ErrorLog) do
			ErrorLog[K] = nil
		end

		CurrentDate = Date
	end

	QueueSave = nil
end

-- Stores an error into the error log table.
local function SaveError(File, Realm, Error)
	local Addon

	if File then
		Addon = string.match(File, FilePattern) or File
	else
		Addon = "unknown"
	end

	local Table = GetTable(Addon, Realm)
	local Count = Table[Error] or 0

	Table[Error] = Count + 1

	if not QueueSave then
		timer.Simple(1, SaveErrors)

		QueueSave = true
	end
end

hook.Add("Initialize", Identifier, function()
	CurrentDate = os.date("%Y-%m-%d")

	hook.Remove("Initialize", Identifier)
end)

local function FullError(Error, Stack)
	for k, v in ipairs(Stack) do
		if k > 1 then
			local StackNum = k - 1
			local Indent = string.rep("  ", StackNum)
			local FuncName = v.name ~= "" and v.name or "unknown"
			Error = Error .. string.format("\n%s%s. %s - %s:%s", Indent, StackNum, FuncName, v.short_src, v.currentline)
		end
	end

	return Error
end

hook.Add("LuaError", Identifier, function(_, Error, File, _, _, Stack)
	Error = FullError(Error, Stack)

	SaveError(File, "server", Error)
end)

hook.Add("ClientLuaError", Identifier, function(_, Error, File, _, _, Stack)
	Error = FullError(Error, Stack)

	SaveError(File, "client", Error)
end)

hook.Add("Shutdown", Identifier, SaveErrors)