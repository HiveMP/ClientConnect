file(GLOB lua_files
    "lua/*.c"
)
file(GLOB lua_curl_files
    "lua-curl/*.c"
)

include_directories(SYSTEM lua/)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../curl/include)

find_program(
	LUA_EXE 
	NAMES lua lua53 lua52 lua51
	PATHS ${CMAKE_CURRENT_SOURCE_DIR}/../lua-win32)

add_custom_command(
	OUTPUT lua-ffi/call_x86.h
	COMMAND ${LUA_EXE} ARGS dynasm/dynasm.lua -LNE -D X32WIN -o call_x86.h call_x86.dasc
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/lua-ffi
)

add_custom_command(
	OUTPUT lua-ffi/call_x64.h
	COMMAND ${LUA_EXE} ARGS dynasm/dynasm.lua -LNE -D X64 -o call_x64.h call_x86.dasc
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/lua-ffi
)

add_custom_command(
	OUTPUT lua-ffi/call_x64win.h
	COMMAND ${LUA_EXE} ARGS dynasm/dynasm.lua -LNE -D X64 -D X64WIN -o call_x64win.h call_x86.dasc
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/lua-ffi
)

add_custom_command(
	OUTPUT lua-ffi/call_arm.h
	COMMAND ${LUA_EXE} ARGS dynasm/dynasm.lua -LNE -o call_arm.h call_arm.dasc
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/lua-ffi
)

add_library(
	HiveMP.ClientConnect SHARED
	${lua_files}
	${lua_curl_files}
	lua-ffi/call.c
	lua-ffi/ctype.c
	lua-ffi/ffi.c
	lua-ffi/parser.c
	lua-ffi/call_x86.h
	lua-ffi/call_x64.h
	lua-ffi/call_x64win.h
	lua-ffi/call_arm.h
	connect.cpp
	connect.impl.cpp
	vfiles.cpp)

target_include_directories(HiveMP.ClientConnect PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(HiveMP.ClientConnect libcurl)

configure_file(lua-curl/lua/cURL.lua ${CMAKE_BINARY_DIR}/cURL.lua COPYONLY)
configure_file(lua-curl/lua/cURL/safe.lua ${CMAKE_BINARY_DIR}/cURL/safe.lua COPYONLY)
configure_file(lua-curl/lua/cURL/utils.lua ${CMAKE_BINARY_DIR}/cURL/utils.lua COPYONLY)
configure_file(lua-curl/lua/cURL/impl/cURL.lua ${CMAKE_BINARY_DIR}/cURL/impl/cURL.lua COPYONLY)