ffi = require("ffi")
ffi.cdef[[
bool SteamAPI_Init();
int SteamAPI_GetHSteamUser();
int SteamAPI_GetHSteamPipe();
intptr_t SteamInternal_CreateInterface(const char* ver);
intptr_t SteamAPI_ISteamClient_GetISteamFriends(intptr_t instancePtr, int hSteamUser, int hSteamPipe, const char* pchVersion);
const char* SteamAPI_ISteamFriends_GetPersonaName(intptr_t instancePtr);
int SteamAPI_ISteamFriends_GetFriendCount(intptr_t instancePtr, int iFriendFlags);
uint64_t SteamAPI_ISteamFriends_GetFriendByIndex(intptr_t instancePtr, int iFriend, int iFriendFlags);
int SteamAPI_ISteamFriends_GetFriendRelationship(intptr_t instancePtr, uint64_t steamIDFriend);
int SteamAPI_ISteamFriends_GetFriendPersonaState(intptr_t instancePtr, uint64_t steamIDFriend);
const char* SteamAPI_ISteamFriends_GetFriendPersonaName(intptr_t instancePtr, uint64_t steamIDFriend);
]]
if ffi.os == "Linux" then
    if ffi.arch == "x64" then
        return ffi.load("linux64/libsteam_api.so")
    elseif ffi.arch == "x86" then
        return ffi.load("linux32/libsteam_api.so")
    else
        return "none"
    end
elseif ffi.os == "OSX" then
    if ffi.arch == "x64" then
        return ffi.load("libsteam_api.dylib")
    elseif ffi.arch == "x86" then
        -- libsteam_api.dylib causes a segmentation fault on 32-bit macOS, so
        -- we don't support this configuration. In the future, macOS is moving
        -- to 64-bit only systems, and most games will be running in 64-bit
        -- mode on any modern macOS anyway.
        return "none"
    else
        return "none"
    end
elseif ffi.os == "Windows" then
    if ffi.arch == "x64" then
        return ffi.load("steam_api64")
    elseif ffi.arch == "x86" then
        return ffi.load("steam_api")
    else
        return "none"
    end
end