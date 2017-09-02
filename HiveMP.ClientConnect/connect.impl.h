#ifndef _CONNECT_IMPL_H
#define _CONNECT_IMPL_H 1

void cci_map_chunk(const char* name, void* data, int len);
void cci_free_chunk(const char* name);
void cci_run(const char* name);
bool cci_is_hotpatched(const char* api, const char* operation);
char* cci_call_hotpatch(const char* api, const char* operation, const char* endpoint, const char* apiKey, const char* parametersAsJson, int* statusCode);
#endif