#include "lua/lua.hpp"
#include "connect.impl.h"

#if WIN32
#define DLLEXPORT __declspec(dllexport)
#else
#define DLLEXPORT
#endif

extern "C"
{
    DLLEXPORT void cc_load(const char* lua)
    {
        cci_load(lua);
    }

    DLLEXPORT bool cc_is_hotpatched(const char* api, const char* operation)
    {
        return cci_is_hotpatched(api, operation);
    }

    DLLEXPORT const char* cc_call_hotpatch(const char* api, const char* operation, const char* apiKey, const char* parametersAsJson, int* statusCode)
    {
        return cci_call_hotpatch(api, operation, apiKey, parametersAsJson, statusCode);
    }
}