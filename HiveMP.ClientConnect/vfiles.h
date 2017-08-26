#ifndef VFILES_H
#define VFILES_H 1

#include <string>
#include <map>
#include "lua/lua.hpp"

extern std::map<std::string, void*>* _vfiles;
extern std::map<std::string, int>* _vfiles_size;

void vfile_init_if_needed();
void vfile_setup_searchers(lua_State* L);
bool vfile_exists(const char* name);
void vfile_get(const char* name, void** data, int* len);
void vfile_set(const char* name, void* data, int len);
void vfile_unset(const char* name);

#endif