#include "connect.impl.h"
#include "vfiles.h"
#include "lua/lua.hpp"
#include "lua-ffi/ffi.h"
#include "lua-curl/lcurl.h"
#include <string>
#include <map>

#define DEFINE_LUA_FUNC(name) \
    lua_pushcfunction(_lua, _ccl_ ## name); \
    lua_setglobal(_lua, #name);
#define DEFINE_LUA_LIB(name) \
	lua_getglobal(_lua, "package"); \
	lua_pushstring(_lua, "preload"); \
	lua_gettable(_lua, -2); \
	lua_pushcclosure(_lua, luaopen_ ## name, 0); \
	lua_setfield(_lua, -2, #name); \
	lua_settop(_lua, 0);

std::map<std::string, std::string>* _hotpatches = nullptr;
lua_State* _lua = nullptr;



int _ccl_register_hotpatch(lua_State *L)
{
    auto id = luaL_checkstring(L, 1);
    auto handler = luaL_checkstring(L, 2);

    if (id != nullptr && handler != nullptr && _hotpatches != nullptr)
    {
        (*_hotpatches)[id] = handler;
        lua_pushboolean(L, true);
    }
    else
    {
        lua_pushboolean(L, false);
    }

    return 1;
}

void _cci_init_if_needed()
{
    if (_hotpatches == nullptr)
    {
        _hotpatches = new std::map<std::string, std::string>();
    }

	vfile_init_if_needed();

    if (_lua == nullptr)
    {
        _lua = luaL_newstate();
        luaL_openlibs(_lua);
		DEFINE_LUA_LIB(ffi);
		DEFINE_LUA_LIB(lcurl);
		DEFINE_LUA_LIB(lcurl_safe);
        DEFINE_LUA_FUNC(register_hotpatch);
		vfile_setup_searchers(_lua);
    }
}

void cci_map_chunk(const char* name_raw, void* data, int len)
{
	_cci_init_if_needed();

	vfile_set(name_raw, data, len);
}

void cci_free_chunk(const char* name_raw)
{
	_cci_init_if_needed();

	vfile_unset(name_raw);
}

void cci_run(const char* name_raw)
{
	std::string name(name_raw);

	_cci_init_if_needed();

	if (!vfile_exists(name_raw))
	{
		fprintf(stderr, "no such chunk loaded: %s", name);
		return;
	}

	void* chunk;
	int size;
	vfile_get(name_raw, &chunk, &size);
	int error = luaL_loadbuffer(_lua, (const char*)chunk, size, name.c_str());
	if (error)
	{
		fprintf(stderr, "%s", lua_tostring(_lua, -1));
		lua_pop(_lua, 1);  /* pop error message from the stack */
	}

	error = lua_pcall(_lua, 0, 0, 0, 0);
	if (error)
	{
		fprintf(stderr, "%s", lua_tostring(_lua, -1));
		lua_pop(_lua, 1);  /* pop error message from the stack */
	}
}

bool cci_is_hotpatched(const char* api_raw, const char* operation_raw)
{
    _cci_init_if_needed();

    std::string api(api_raw);
    std::string operation(operation_raw);

    auto id = api + ":" + operation;

    return _hotpatches->find(id) != _hotpatches->end();
}

static void stackDump(lua_State *L) {
	int i;
	int top = lua_gettop(L);
	for (i = 1; i <= top; i++) {  /* repeat for each level */
		int t = lua_type(L, i);
		switch (t) {

		case LUA_TSTRING:  /* strings */
			printf("`%s'\n", lua_tostring(L, i));
			break;

		case LUA_TBOOLEAN:  /* booleans */
			printf(lua_toboolean(L, i) ? "true\n" : "false\n");
			break;

		case LUA_TNUMBER:  /* numbers */
			printf("%g\n", lua_tonumber(L, i));
			break;

		default:  /* other values */
			printf("%s\n", lua_typename(L, t));
			break;

		}
		//printf("  ");  /* put a separator */
	}
	printf("\n");  /* end the listing */
}

char* cci_call_hotpatch(
	const char* api_raw, 
	const char* operation_raw, 
	const char* endpoint_raw, 
	const char* apiKey_raw, 
	const char* parametersAsJson_raw, 
	int32_t* statusCode_raw)
{
    _cci_init_if_needed();

	const char* result_to_copy = nullptr;
	bool pop_lua_after_copy = false;

    if (!cci_is_hotpatched(api_raw, operation_raw))
    {
        *statusCode_raw = 400;
        result_to_copy = "{\"code\": 7001, \"message\": \"Request is not hotpatched, make a direct call to the servers\", \"fields\": null}";
    }
	else
	{
		std::string api(api_raw);
		std::string operation(operation_raw);

		auto id = api + ":" + operation;

		auto lua_func_name = (*_hotpatches)[id];

		lua_getglobal(_lua, lua_func_name.c_str());
		lua_pushstring(_lua, id.c_str());
		lua_pushstring(_lua, endpoint_raw);
		lua_pushstring(_lua, apiKey_raw);
		lua_pushstring(_lua, parametersAsJson_raw);

		if (lua_pcall(_lua, 4, 2, 0) != 0)
		{
			*statusCode_raw = 500;
			printf("error: %s\n", lua_tostring(_lua, -1));
			lua_pop(_lua, 1);
			result_to_copy = "{\"code\": 7002, \"message\": \"An internal error occurred while running hotpatch\", \"fields\": null}";
		}
		else
		{
			int isnum;
			lua_Integer d = lua_tointegerx(_lua, 1, &isnum);
			const char* s = lua_tostring(_lua, 2);
			if (!isnum || s == nullptr)
			{
				*statusCode_raw = 500;
				lua_pop(_lua, 2);
				result_to_copy = "{\"code\": 7002, \"message\": \"The hotpatch return value was not in an expected format\", \"fields\": null}";
			}
			else
			{
				*statusCode_raw = (int)d;
				result_to_copy = s;
				pop_lua_after_copy = true;
			}
		}
	}

	auto len = strlen(result_to_copy) + 1;
	char* result = (char*)malloc(len);
	memcpy(result, result_to_copy, len);
	result[len - 1] = 0;

	if (pop_lua_after_copy)
	{
		lua_pop(_lua, 2);
	}

	// Caller must free after usage.
	return result;
}