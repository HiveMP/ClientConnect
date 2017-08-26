param()

# This is only used on the build server to copy the Steam API DLLs from a known
# location. If you are building the Client Connect SDK yourself, you will need
# to download the Steam SDK (we can't redistribute it) and copy the DLLs in place.
Copy-Item -Force C:\Users\Redpoint\Documents\SteamworksSDK138a\sdk\redistributable_bin\steam_api.dll $PSScriptRoot\
Copy-Item -Force C:\Users\Redpoint\Documents\SteamworksSDK138a\sdk\redistributable_bin\win64\steam_api.dll $PSScriptRoot\