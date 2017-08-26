local ffi = require("ffi")
local json = require("json")
local steam = require("steam")

local steamInst = {}
local didSteamInit = false

function init()
	if not didSteamInit then
		if not steam.SteamAPI_Init() then return end
		local user = steam.SteamAPI_GetHSteamUser()
		if user == nil then return end
		local pipe = steam.SteamAPI_GetHSteamPipe()
		if pipe == nil then return end
		local client = steam.SteamInternal_CreateInterface("SteamClient017")
		if client == nil then return end
		local friends = steam.SteamAPI_ISteamClient_GetISteamFriends(client, user, pipe, "SteamFriends015")
		if friends == nil then return end
		steamInst = { user = user, pipe = pipe, client = client, friends = friends }
		didSteamInit = true
	end
end

function friends_get_hotpatch(id, api_key, parameters_json)
	local params = json.decode(parameters_json)

	init()
	if not didSteamInit then
		return 404, json.encode({code = 7002, message = "Unable to use Steam APIs!", fields = nil })
	end

	local friends = {}
	local friendCount = steam.SteamAPI_ISteamFriends_GetFriendCount(steamInst.friends, 0xFFFF)
	for i = 0, friendCount do
		local friendId = steam.SteamAPI_ISteamFriends_GetFriendByIndex(steamInst.friends, i, 0xFFFF)
		local friendRel = steam.SteamAPI_ISteamFriends_GetFriendRelationship(steamInst.friends, friendId)
		local friendState = steam.SteamAPI_ISteamFriends_GetFriendPersonaState(steamInst.friends, friendId)
		local friendName = ffi.string(steam.SteamAPI_ISteamFriends_GetFriendPersonaName(steamInst.friends, friendId))

		table.insert(friends, {
			id = tostring(friendId),
			relationship = tonumber(friendRel),
			state = tonumber(friendState),
			name = tostring(friendName)
		})
	end

	return 200, json.encode(friends)
end

-- Hotpatch REST calls to GET https://friends-api.hivemp.com/v1/friends to our Lua method instead
register_hotpatch("friends:friendsGET", "friends_get_hotpatch")