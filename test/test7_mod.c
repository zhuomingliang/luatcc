#include <lua.h>

extern int foo(int);

int luaopen_test7_mod(lua_State* L)
{
	foo(32);
	lua_pushstring(L, "Hello World!");
	return 1;
}

