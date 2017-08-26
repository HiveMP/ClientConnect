#ifndef _CONNECT_IMPL_H
#define _CONNECT_IMPL_H 1

void cci_load(const char* lua);
bool cci_is_hotpatched(const char* api, const char* operation);
const char* cci_call_hotpatch(const char* api, const char* operation, const char* apiKey, const char* parametersAsJson, int* statusCode);
#endif