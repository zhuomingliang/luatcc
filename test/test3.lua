io.write("Normal behaviour: "); io.flush()

package.path = './?.lua;../src/?.lua'
package.cpath = '../src/?.so'
require 'tcc.loader'

local mod = require 'test3_mod'

assert(mod=="Hello World!")

io.write("OK\n")
