#ifndef _CONNECT_H
#define CONNECT_H 1

#include <stdbool.h>

#if WIN32
#define DLLIMPORT __declspec(dllimport)
#else
#define DLLIMPORT
#endif

DLLIMPORT void cc_load(const char* lua);
DLLIMPORT bool cc_is_hotpatched(const char* api, const char* operation);
DLLIMPORT const char* cc_call_hotpatch(const char* api, const char* operation, const char* apiKey, const char* parametersAsJson, int* statusCode);
#endif