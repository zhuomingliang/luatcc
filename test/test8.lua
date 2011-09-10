io.write("Module not found: "); io.flush()

package.path = './?.lua;../src/?.lua'
package.cpath = '../src/?.so'
require 'tcc.loader'

local success,mod = pcall(require, 'test8_mod')
assert(not success and mod==[[
module 'test8_mod' not found:
	no field package.preload['test8_mod']
	no file './test8_mod.lua'
	no file '../src/test8_mod.lua'
	no file '../src/test8_mod.so'
	no file './test8_mod.c']])

io.write("OK\n")

