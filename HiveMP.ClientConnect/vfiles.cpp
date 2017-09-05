#include "vfiles.h"
#include <stdlib.h>
#include <string.h>

std::map<std::string, void*>* _vfiles = nullptr;
std::map<std::string, int>* _vfiles_size = nullptr;

static int readable(const char *filename)
{
	std::string name(filename);
	return _vfiles->find(name) != _vfiles->end();
}

static const char *pushnexttemplate(lua_State *L, const char *path)
{
	const char *l;
	while (*path == *LUA_PATH_SEP) path++;  /* skip separators */
	if (*path == '\0') return NULL;  /* no more templates */
	l = strchr(path, *LUA_PATH_SEP);  /* find next separator */
	if (l == NULL) l = path + strlen(path);
	lua_pushlstring(L, path, l - path);  /* template */
	return l;
}

static const char *searchpath(
	lua_State *L,
	const char *name,
	const char *path,
	const char *sep,
	const char *dirsep)
{
	luaL_Buffer msg;  /* to build error message */
	luaL_buffinit(L, &msg);
	if (*sep != '\0')  /* non-empty separator? */
	{
		name = luaL_gsub(L, name, sep, dirsep);  /* replace it by 'dirsep' */
	}
	while ((path = pushnexttemplate(L, path)) != NULL)
	{
		const char *filename = luaL_gsub(L, lua_tostring(L, -1),
			LUA_PATH_MARK, name);
		lua_remove(L, -2);  /* remove path template */
		if (readable(filename))  /* does file exist and is readable? */
			return filename;  /* return that file name */
		lua_pushfstring(L, "\n\tno file '%s'", filename);
		lua_remove(L, -2);  /* remove file name */
		luaL_addvalue(&msg);  /* concatenate error msg. entry */
	}
	luaL_pushresult(&msg);  /* create error message */
	return NULL;  /* not found */
}

static const char *findfile(
	lua_State *L,
	const char *name,
	const char *pname,
	const char *dirsep)
{
	const char *path = "?.lua";
	if (path == NULL)
	{
		luaL_error(L, "'package.%s' must be a string", pname);
	}
	return searchpath(L, name, path, ".", dirsep);
}

static int checkload(lua_State *L, int stat, const char *filename) {
	if (stat) {  /* module loaded successfully? */
		lua_pushstring(L, filename);  /* will be 2nd argument to module */
		return 2;  /* return open function and file name */
	}
	else
		return luaL_error(L, "error loading module '%s' from file '%s':\n\t%s",
			lua_tostring(L, 1), filename, lua_tostring(L, -1));
}

static int searcher_Lua(lua_State *L) {
	const char *filename;
	const char *name = luaL_checkstring(L, 1);
	filename = findfile(L, name, "path", "/");
	if (filename == NULL) return 1;  /* module not found in this path */
	void* chunk;
	int size;
	vfile_get(filename, &chunk, &size);
	return checkload(L, (luaL_loadbuffer(L, (const char*)chunk, size, filename) == LUA_OK), filename);
}

static int searcher_preload(lua_State *L)
{
	const char *name = luaL_checkstring(L, 1);
	lua_getfield(L, LUA_REGISTRYINDEX, LUA_PRELOAD_TABLE);
	if (lua_getfield(L, -1, name) == LUA_TNIL)  /* not found? */
	{
		lua_pushfstring(L, "\n\tno field package.preload['%s']", name);
	}
	return 1;
}

static void createsearcherstable(lua_State *L) 
{
	lua_getglobal(L, "package");
	static const lua_CFunction searchers[] =
	{ searcher_preload, searcher_Lua, NULL };
	int i;
	/* create 'searchers' table */
	lua_createtable(L, sizeof(searchers) / sizeof(searchers[0]) - 1, 0);
	/* fill it with predefined searchers */
	for (i = 0; searchers[i] != NULL; i++) {
		lua_pushvalue(L, -2);  /* set 'package' as upvalue for all searchers */
		lua_pushcclosure(L, searchers[i], 1);
		lua_rawseti(L, -2, i + 1);
	}
	lua_setfield(L, -2, "searchers");  /* put it in field 'searchers' */
	lua_pop(L, 1);
}

void vfile_init_if_needed()
{
	if (_vfiles == nullptr)
	{
		_vfiles = new std::map<std::string, void*>();
	}

	if (_vfiles_size == nullptr)
	{
		_vfiles_size = new std::map<std::string, int>();
	}
}

void vfile_setup_searchers(lua_State* L)
{
	vfile_init_if_needed();

	createsearcherstable(L);
}

bool vfile_exists(const char* name_raw)
{
	vfile_init_if_needed();

	std::string name(name_raw);

	return _vfiles->find(name) != _vfiles->end();
}

void vfile_get(const char* name_raw, void** data, int* len)
{
	vfile_init_if_needed();

	std::string name(name_raw);

	if (!vfile_exists(name_raw))
	{
		*data = nullptr;
		*len = 0;
		return;
	}

	*data = (*_vfiles)[name];
	*len = (*_vfiles_size)[name];
}

void vfile_set(const char* name_raw, void* data, int len)
{
	vfile_init_if_needed();

	std::string name(name_raw);

	if (_vfiles->find(name) != _vfiles->end())
	{
		// Free existing chunk first.
		vfile_unset(name_raw);
	}

	void* copy = malloc(len);
	memcpy(copy, data, len);

	(*_vfiles)[name] = copy;
	(*_vfiles_size)[name] = len;
}

void vfile_unset(const char* name_raw)
{
	vfile_init_if_needed();

	std::string name(name_raw);
	if (_vfiles->find(name) != _vfiles->end())
	{
		free((*_vfiles)[name]);
	}
	_vfiles->erase(name);
	_vfiles_size->erase(name);
}