add_executable(HiveMP.SteamTest main.cpp)

target_link_libraries(HiveMP.SteamTest LINK_PUBLIC HiveMP.ClientConnect)

configure_file(json.lua ${CMAKE_BINARY_DIR}/json.lua COPYONLY)
configure_file(test.lua ${CMAKE_BINARY_DIR}/test.lua COPYONLY)
configure_file(steam.lua ${CMAKE_BINARY_DIR}/steam.lua COPYONLY)
configure_file(steam_api.dll ${CMAKE_BINARY_DIR}/steam_api.dll COPYONLY)
configure_file(steam_api64.dll ${CMAKE_BINARY_DIR}/steam_api64.dll COPYONLY)
configure_file(steam_appid.txt ${CMAKE_BINARY_DIR}/steam_appid.txt COPYONLY)

if(LINUX)
  set_target_properties(HiveMP.SteamTest PROPERTIES OUTPUT_NAME "HiveMP.SteamTest-exe")
endif()