module(..., package.seeall)

local luatcc = require(_PACKAGE:sub(1,-2))

local function new_context()
	local context = luatcc.new()
--	context:add_include_path("some/path/to/header/files")
--	context:add_library_path("some/path/to/library/files")
	return context
end
local DIRSEP = '/'

local function search(modulename)
	-- Read source
	local filename
	local file
	local errmsg = ""
	for path in package.tccpath:gmatch"[^;]+" do
		filename = path:gsub("%?", (modulename:gsub("%.", DIRSEP)))
		file = io.open(filename)
		if file then
			break
		end
		errmsg = errmsg.."\n\tno file '"..filename.."'"
	end
	if not file then
		return errmsg
	end
	local source = assert(file:read"*a")
	-- Get luatcc pragma commands
	local commands = {}
	for command,argstr in source:gmatch"luatcc[%s]*([a-z_]*)%(([^)]*)%)" do
		commands[command] = commands[command] or {}
		local args = {}
		for arg in argstr:gmatch"[^,]+" do
			table.insert(args, arg)
		end
		table.insert(commands[command], args)
	end
	-- Interpret pragma commands
	--- use_library
	local libdeps = {}
	if commands.use_library then
		for _,args in ipairs(commands.use_library) do
			local libdep = args[1]
			table.insert(libdeps, libdep)
		end
	end

	local context = new_context()
	local result,success,errmsg
	-- Compile file
	result,success,errmsg = pcall(context.compile, context, source, filename)
	if not result then
		error("error loading module '"..modulename.."' from file '"..filename.."':\n\t"..success, 0)
	end
	assert(success, errmsg)
	-- Add libraries
	for _,libdep in ipairs(libdeps) do
		result,success,errmsg = pcall(context.add_library, context, libdep)
		if not result then
			error("error loading module '"..modulename.."' from file '"..filename.."':\n\t"..success, 0)
		end
		assert(success, errmsg)
	end
	-- Relocate binary code
	result,success,errmsg = pcall(context.relocate, context)
	if not result then
		error("error loading module '"..modulename.."' from file '"..filename.."':\n\t"..success, 0)
	end
	assert(success, errmsg)
	-- Extract symbol
	local chunk
	result,chunk,errmsg = pcall(context.get_symbol, context, "luaopen_"..string.gsub(modulename, "%.", "_"))
	if not result then
		error("error loading module '"..modulename.."' from file '"..filename.."':\n\t"..chunk, 0)
	end
	assert(chunk, errmsg)
	return chunk
end

local priority = #package.loaders+1
if type(package.tccpriority)=='number' and package.tccpriority>=1 then
	priority = math.min(priority, package.tccpriority)
end
table.insert(package.loaders, priority, search)

package.tccpath = package.tccpath or "./?.c"

--[[
Copyright (c) 2009-2010 Jérôme Vuarand

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]
