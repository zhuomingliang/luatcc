#include <lua.h>

int luaopen_test3_mod(lua_State* L)
{
	lua_pushstring(L, "Hello World!");
	return 1;
}

