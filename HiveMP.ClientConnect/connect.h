#ifndef _CONNECT_H
#define CONNECT_H 1

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdbool.h>
#include <stdint.h>

#if WIN32
#define DLLIMPORT __declspec(dllimport)
#else
#define DLLIMPORT
#endif

	DLLIMPORT void cc_map_chunk(const char* name, void* data, int len);
	DLLIMPORT void cc_free_chunk(const char* name);
	DLLIMPORT void cc_set_startup(const char* name);
	DLLIMPORT void cc_set_config(void* data, int len);
	DLLIMPORT bool cc_is_hotpatched(const char* api, const char* operation);
	DLLIMPORT char* cc_call_hotpatch(const char* api, const char* operation, const char* endpoint, const char* apiKey, const char* parametersAsJson, int32_t* statusCode);
	DLLIMPORT void cc_free_string(char* ptr);

#ifdef __cplusplus
}
#endif

#endif