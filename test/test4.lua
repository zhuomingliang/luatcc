io.write("Lua module loading error: "); io.flush()

package.path = './?.lua;../src/?.lua'
package.cpath = '../src/?.so'
local success,mod = pcall(require, 'test4_mod')
assert(not success and mod==[[
error loading module 'test4_mod' from file './test4_mod.lua':
	./test4_mod.lua:4: unexpected symbol near '<eof>']], mod)

io.write("OK\n")

