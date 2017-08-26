file(GLOB lua_files
    "lua/*.c"
)

include_directories(SYSTEM lua/)

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
	lua-ffi/call.c
	lua-ffi/ctype.c
	lua-ffi/ffi.c
	lua-ffi/parser.c
	lua-ffi/call_x86.h
	lua-ffi/call_x64.h
	lua-ffi/call_x64win.h
	lua-ffi/call_arm.h
	connect.cpp
	connect.impl.cpp)

target_include_directories(HiveMP.ClientConnect PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})