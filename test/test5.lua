io.write("Binary module loading error: "); io.flush()

package.path = './?.lua;../src/?.lua'
package.cpath = '../src/?.so'
local success,mod = pcall(require, 'test5_mod')
assert(not success and mod==[[
module 'test5_mod' not found:
	no field package.preload['test5_mod']
	no file './test5_mod.lua'
	no file '../src/test5_mod.lua'
	no file '../src/test5_mod.so']])

io.write("OK\n")

