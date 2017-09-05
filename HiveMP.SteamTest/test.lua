local ffi = require("ffi")
local json = require("json")
local steam = require("steam")

local steamInst = {}
local didSteamInit = false

local curl = require("cURL")

local clock = os.clock
function sleep(n)  -- seconds
  local t0 = clock()
  while clock() - t0 <= n do end
end

print("TEST: test.lua started")

function init()
	if not didSteamInit then
		if steam ~= "none" then
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
		end
		didSteamInit = true
	end
end

function make_hive_request(endpoint, method, path, api_key, querystring, body)
	local result = ""
	local noRetry = true
	local delay = 1
	repeat
		noRetry = true
		print("making HTTP request...")
		local c = curl.easy
		{
			url = endpoint .. path,
			customrequest = method,
			httpheader = {
				"X-API-Key: " .. api_key,
				"Content-Length: " .. string.len(body),
				"Accept: application/json",
			},
			readfunction = function()
				return body
			end,
			debugfunction = function(d, l, a)
			end,
			writefunction = function(str)
				result = json.decode(str)
			end,
			upload = 0
		}
		c:perform()
		code, _ = c:getinfo_response_code()
		c:close()
		if code >= 200 and code < 300 then
			-- success
		else
			-- parse error to check for 6001
			if result.code == 6001 then
				print("got 6001 from server! sleeping for " .. delay .. " seconds!")
				noRetry = false
				sleep(delay)
				delay = delay * 2
			else
				return false, {
					httpstatus = code,
					code = result.code,
					message = result.message,
					fields = result.fields
				}
			end
		end
	until noRetry
	return true, result
end

function session_put_hotpatch(id, endpoint, api_key, parameters_json)
	local params = json.decode(parameters_json)

	init()

	local success, session = make_hive_request(
		endpoint,
		"PUT",
		"/v1/session-notfound",
		api_key,
		{},
		"")

	if not success then
		print("TEST PASS: Got failure when trying to access /v1/session-notfound")
		print(json.encode(session))
	else
		print("TEST FAIL: Got success when trying to access /v1/session-notfound")
		print(json.encode(session))
	end

	success, session = make_hive_request(
		endpoint,
		"PUT",
		"/v1/session",
		api_key,
		{},
		"")

	if success then
		print("TEST PASS: Got success when trying to access /v1/session")
		print(json.encode(session))
	else
		print("TEST FAIL: Got failure when trying to access /v1/session")
		print(json.encode(session))
	end
	
	local friends = {}
	if didSteamInit then
		if steam ~= "none" then
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
		end
	end

	-- Append friend information to response
	session.friends = friends

	if success then
		return 200, json.encode(session)
	else
		return success.httpstatus, json.encode(session)
	end
end

-- Hotpatch REST calls
register_hotpatch("temp-session:sessionPUT", "session_put_hotpatch")