local file    = file
local os      = os
local string  = string
local Pattern = ".lua:%d+:" -- Will store messages that point out a Lua file
local Message = "[%s]\n%s\n\n"
local Folder  = "error_logs"
local Path    = Folder .. "/%s.txt"

hook.Add("EngineSpew", "Error Logger", function(_, Error)
	if not string.match(Error, Pattern) then return end

	local File    = Path:format(os.date("%Y-%m-%d"))
	local Content = Message:format(os.date("%X"), Error:Trim())

	if file.Exists(File, "DATA") then
		file.Append(File, Content)
	else
		if not file.Exists(Folder, "DATA") then
			file.CreateDir(Folder)
		end

		file.Write(File, Content)
	end
end)
