io.write("luatcc compilation: "); io.flush()

package.path = './?.lua;../src/?.lua'
package.cpath = '../src/?.so'
local luatcc = require 'tcc'
local context = luatcc.new()

context:compile([[
#include <lua.h>
int foo(lua_State* L)
{
	lua_pushstring(L, "Hello World!");
	return 1;
}
]])
context:relocate()
local foo = context:get_symbol("foo")
--print(foo())

io.write("OK\n")
