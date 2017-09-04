#include "lua/lua.hpp"
#include "connect.impl.h"
#include <stdint.h>
#include <stdlib.h>

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

	DLLEXPORT void cc_set_startup(const char* name)
	{
		cci_set_startup(name);
	}

	DLLEXPORT void cc_set_config(void* data, int len)
	{
		cci_set_config(data, len);
	}

    DLLEXPORT bool cc_is_hotpatched(const char* api, const char* operation)
    {
        return cci_is_hotpatched(api, operation);
    }

    DLLEXPORT char* cc_call_hotpatch(const char* api, const char* operation, const char* endpoint, const char* apiKey, const char* parametersAsJson, int32_t* statusCode)
    {
        return cci_call_hotpatch(api, operation, endpoint, apiKey, parametersAsJson, statusCode);
    }

	DLLEXPORT void cc_free_string(char* ptr)
	{
		// C# can't free a C-style string on return, even though it can marshal it.
		free(ptr);
	}
}