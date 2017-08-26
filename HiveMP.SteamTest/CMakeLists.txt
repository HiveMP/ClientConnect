add_executable(HiveMP.SteamTest main.cpp)

target_link_libraries(HiveMP.SteamTest LINK_PUBLIC HiveMP.ClientConnect)

configure_file(json.lua ${CMAKE_BINARY_DIR}/json.lua COPYONLY)
configure_file(test.lua ${CMAKE_BINARY_DIR}/test.lua COPYONLY)