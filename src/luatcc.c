#include <lua.h>
#include <lauxlib.h>
#include <libtcc.h>


/* function context:compile(source [, chunkname]) return true end */
static int lua__tcc__compile(lua_State* L)
{
	TCCState* tcc;
	const char* chunkname = NULL;
	const char* code;
	
	luaL_checktype(L, 1, LUA_TUSERDATA);
	tcc = *(TCCState**)lua_touserdata(L, 1);
	
	code = luaL_checkstring(L, 2);

	if (lua_isstring(L, 3))
		chunkname = lua_tostring(L, 3);
	
	/* compile */
	if (tcc_compile_named_string(tcc, code, chunkname))
	{
		return luaL_error(L, "unknown compilation error");
	}
	
	lua_pushboolean(L, 1);
	return 1;
}

/* function context:add_library(libraryname) return true end */
static int lua__tcc__add_library(lua_State* L)
{
	TCCState* tcc;
	const char* libname = NULL;
	
	luaL_checktype(L, 1, LUA_TUSERDATA);
	tcc = *(TCCState**)lua_touserdata(L, 1);
	
	libname = luaL_checkstring(L, 2);
	
	/* add libs */
	if (tcc_add_library(tcc, libname))
		return luaL_error(L, "can't load library %s", libname);
	
	lua_pushboolean(L, 1);
	return 1;
}

/* function context:relocate() return true end */
static int lua__tcc__relocate(lua_State* L)
{
	TCCState* tcc;
#ifdef USE_TCC_0_9_23
#else
	int size, result;
	void* ptr;
#endif
	
	luaL_checktype(L, 1, LUA_TUSERDATA);
	tcc = *(TCCState**)lua_touserdata(L, 1);
	
	/* link */
#ifdef USE_TCC_0_9_23
	if (tcc_relocate(tcc))
#else
	size = tcc_relocate(tcc, NULL);
	ptr = lua_newuserdata(L, size);
	result = tcc_relocate(tcc, ptr);
	if (result == -1)
#endif
		return luaL_error(L, "unknown relocation (link) error");
	
#ifdef USE_TCC_0_9_23
#else
	/* keep a reference to the memory block */
	lua_getfenv(L, 1);
	lua_insert(L, -2);
	lua_setfield(L, -2, "relocation memory");
#endif
	
	lua_pushboolean(L, 1);
	return 1;
}

/* function context:get_symbol(symbolname) return symbol end */
static int lua__tcc__get_symbol(lua_State* L)
{
	TCCState* tcc;
	const char* funcname = NULL;
#ifdef USE_TCC_0_9_23
	unsigned long sym;
#else
	void* sym;
#endif
	lua_CFunction f;
	
	luaL_checktype(L, 1, LUA_TUSERDATA);
	tcc = *(TCCState**)lua_touserdata(L, 1);
	
	funcname = luaL_checkstring(L, 2);
	
#ifdef USE_TCC_0_9_23
	if (tcc_get_symbol(tcc, &sym, funcname) < 0)
#else
	sym = tcc_get_symbol(tcc, funcname);
	if (!sym)
#endif
		return luaL_error(L, "can't get symbol %s", funcname);
	f = (lua_CFunction)sym;
	
	/* push the function */
#ifdef USE_TCC_0_9_23
	/* keep the state as upvalue */
	lua_pushvalue(L, 1);
#else
	/* keep the relocation memory as upvalue */
	lua_getfenv(L, 1);
	lua_getfield(L, -1, "relocation memory");
#endif
	lua_pushcclosure(L, f, 1);
	
	return 1;
}

/* function context:add_library_path(path) end */
static int lua__tcc__add_library_path(lua_State *L)
{
	TCCState* tcc;
	const char* path;
	
	luaL_checktype(L, 1, LUA_TUSERDATA);
	tcc = *(TCCState**)lua_touserdata(L, 1);
	path = luaL_checkstring (L, 2);
	
	tcc_add_library_path(tcc, path);
	
	return 0;
}

/* function context:add_include_path(path) end */
static int lua__tcc__add_include_path(lua_State *L)
{
	TCCState* tcc;
	const char* path;
	
	luaL_checktype(L, 1, LUA_TUSERDATA);
	tcc = *(TCCState**)lua_touserdata(L, 1);
	path = luaL_checkstring (L, 2);
	
	tcc_add_include_path(tcc, path);
	
	return 0;
}

static int lua__tcc___gc(lua_State* L)
{
	TCCState** ptcc;
	
	luaL_checktype(L, 1, LUA_TUSERDATA);
	ptcc = (TCCState**)lua_touserdata(L, 1);
	
	if (ptcc && *ptcc)
	{
		tcc_delete(*ptcc);
		*ptcc = NULL;
	}
	
	return 0;
}

static const struct luaL_reg tcc_methods[] = {
	{"compile", lua__tcc__compile},
	{"add_library", lua__tcc__add_library},
	{"relocate", lua__tcc__relocate},
	{"get_symbol", lua__tcc__get_symbol},
	{"add_library_path", lua__tcc__add_library_path},
	{"add_include_path", lua__tcc__add_include_path},
	{NULL, NULL}
};

void luatcc__error_func(void* opaque, const char* msg)
{
	luaL_error((lua_State*)opaque, "%s", msg);
}

static int lua__new(lua_State* L)
{
	TCCState* tcc = tcc_new();
	if (!tcc)
		return luaL_error(L, "can't create tcc state");
	
	tcc_set_output_type(tcc, TCC_OUTPUT_MEMORY);
	tcc_set_error_func(tcc, (void*)L, luatcc__error_func);
	
	TCCState** ptcc = (TCCState**)lua_newuserdata(L, sizeof(TCCState*));
	*ptcc = tcc;
	lua_newtable(L); /* Metatable */
	lua_newtable(L); /* __index */
	luaL_register(L, 0, tcc_methods);
	lua_setfield(L, -2, "__index");
	lua_pushcfunction(L, lua__tcc___gc);
	lua_setfield(L, -2, "__gc");
	lua_setmetatable(L, -2);
	
	return 1;
}

static const struct luaL_reg module_functions[] = {
	{"new", lua__new},
	{NULL, NULL}
};

MODULE_API int luaopen_module(lua_State *L)
{
	luaL_register(L, lua_tostring(L, 1), module_functions);
	
	return 0;
}

/*
Copyright (c) 2006-2010 Jérôme Vuarand

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
