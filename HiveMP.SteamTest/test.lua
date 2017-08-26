--local steam = require("steam")
--local ffi = require("ffi")
local json = require("json")

register_hotpatch("admin-session:sessionPUT", "session_put_hotpatch")

function session_put_hotpatch(id, api_key, parameters_json)
	local params = json.decode(parameters_json)
	print("username is: " .. params.username)
	print("password is: " .. params.password)
	return 404, json.encode({
		code = 1001,
		message = "The API call could not be handled",
		fields = ""
	})
end


--[[steam.SteamAPI_Init()

local user = steam.SteamAPI_GetHSteamUser()
local pipe = steam.SteamAPI_GetHSteamPipe()
local client = steam.SteamInternal_CreateInterface("SteamClient017")
local friends = steam.SteamAPI_ISteamClient_GetISteamFriends(client, user, pipe, "SteamFriends015")
local name = steam.SteamAPI_ISteamFriends_GetPersonaName(friends)
print(ffi.string(name))
]]