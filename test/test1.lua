io.write("luatcc loading: "); io.flush()

package.path = './?.lua;../src/?.lua'
package.cpath = '../src/?.so'
local luatcc = require 'tcc'
--assert(luatcc._NAME=="")

io.write("OK\n")
