#include "connect.impl.h"
#include "lua/lua.hpp"
#include <string>
#include <map>

#define DEFINE_LUA_FUNC(name) \
    lua_pushcfunction(_lua, _ccl_ ## name); \
    lua_setglobal(_lua, #name);

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

    if (_lua == nullptr)
    {
        _lua = luaL_newstate();
        luaL_openlibs(_lua);
        DEFINE_LUA_FUNC(register_hotpatch);
    }
}

void cci_load(const char* lua_raw)
{
    _cci_init_if_needed();
}

bool cci_is_hotpatched(const char* api_raw, const char* operation_raw)
{
    _cci_init_if_needed();

    std::string api(api_raw);
    std::string operation(operation_raw);

    auto id = api + ":" + operation;

    return _hotpatches->find(id) != _hotpatches->end();
}

const char* cci_call_hotpatch(const char* api_raw, const char* operation_raw, const char* apiKey_raw, const char* parametersAsJson_raw, int* statusCode_raw)
{
    _cci_init_if_needed();

    if (!cci_is_hotpatched(api_raw, operation_raw))
    {
        *statusCode_raw = 400;
        return "{\"code\": 7001, \"message\": \"Request is not hotpatched, make a direct call to the servers\", \"fields\": null}";
    }

    std::string api(api_raw);
    std::string operation(operation_raw);

    auto id = api + ":" + operation;

    auto lua_func_name = (*_hotpatches)[id];

    lua_getglobal(_lua, lua_func_name.c_str());
    lua_pushstring(_lua, id.c_str());
    lua_pushstring(_lua, apiKey_raw);
    lua_pushstring(_lua, parametersAsJson_raw);

    if (lua_pcall(_lua, 3, 2, 0) != 0)
    {
        *statusCode_raw = 500;
        return "{\"code\": 7002, \"message\": \"An internal error occurred while running hotpatch\", \"fields\": null}";
        //error(L, "error running function `f': %s",
        //    lua_tostring(L, -1));
    }

    *statusCode_raw = (int)luaL_checkinteger(_lua, 1);
    return luaL_checkstring(_lua, 2);
}