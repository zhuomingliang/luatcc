#include <lua.h>

int luaopen_test6_mod(lua_State* L)
{
	lua_pushstring("Hello World!");
	return 1;
}

