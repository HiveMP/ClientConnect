#include "lua/lua.hpp"
#include "connect.impl.h"

#if WIN32
#define DLLEXPORT __declspec(dllexport)
#else
#define DLLEXPORT
#endif

extern "C"
{
	DLLEXPORT void cc_map_chunk(const char* name, void* data, int len)
	{
		cci_map_chunk(name, data, len);
	}

	DLLEXPORT void cc_free_chunk(const char* name)
	{
		cci_free_chunk(name);
	}

	DLLEXPORT void cc_run(const char* name)
	{
		cci_run(name);
	}

    DLLEXPORT bool cc_is_hotpatched(const char* api, const char* operation)
    {
        return cci_is_hotpatched(api, operation);
    }

    DLLEXPORT const char* cc_call_hotpatch(const char* api, const char* operation, const char* endpoint, const char* apiKey, const char* parametersAsJson, int* statusCode)
    {
        return cci_call_hotpatch(api, operation, endpoint, apiKey, parametersAsJson, statusCode);
    }
}