file(GLOB lua_files
    "lua/*.c"
)

add_library(HiveMP.ClientConnect SHARED ${lua_files} connect.cpp connect.impl.cpp)

target_include_directories(HiveMP.ClientConnect PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})