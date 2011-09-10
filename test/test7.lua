io.write("Linking error: "); io.flush()

package.path = './?.lua;../src/?.lua'
package.cpath = '../src/?.so'
require 'tcc.loader'

local success,mod = pcall(require, 'test7_mod')
assert(not success, "loading problematic module unexpectedly succeeded")
assert(mod:gmatch[[
error loading module 'test7_mod' from file '%./test7_mod%.c':
	[^:]+: undefined symbol 'foo']], "unexpected error output: "..mod)

io.write("OK\n")

