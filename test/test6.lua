io.write("Compilation error: "); io.flush()

package.path = './?.lua;../src/?.lua'
package.cpath = '../src/?.so'
require 'tcc.loader'

local success,mod = pcall(require, 'test6_mod')
assert(not success and mod==[[
error loading module 'test6_mod' from file './test6_mod.c':
	<string>:5: warning: assignment from incompatible pointer type]])

io.write("OK\n")

