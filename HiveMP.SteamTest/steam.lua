ffi = require("ffi")
ffi.cdef[[
bool SteamAPI_Init();
int SteamAPI_GetHSteamUser();
int SteamAPI_GetHSteamPipe();
void* SteamInternal_CreateInterface(const char* ver);
void* SteamAPI_ISteamClient_GetISteamFriends(void* instancePtr, int hSteamUser, int hSteamPipe, const char* pchVersion);
const char* SteamAPI_ISteamFriends_GetPersonaName(void* instancePtr);
]]
return ffi.load("steam_api64")