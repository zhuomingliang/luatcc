local charset = ([[
vi: encoding=utf-8
]]):sub(14, -2):upper()

require 'markdown'

local file_index = "index.html"
local lastversion = "1.0.0"


function print(...)
	local t = {...}
	for i=1,select('#', ...) do
		t[i] = tostring(t[i])
	end
	io.write(table.concat(t, '\t')..'\n')
end

local function manlink(name)
	return '<a href="http://www.lua.org/manual/5.1/manual.html#pdf-'..name..'"><code>'..name..'</code></a>'
end

local function manclink(name)
	return '<a href="http://www.lua.org/manual/5.1/manual.html#'..name..'"><code>'..name..'</code></a>'
end

function header()
	print[[
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en"
lang="en">
<head>
<title>Luatcc</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<link rel="stylesheet" href="doc.css" type="text/css"/>
</head>
<body>
]]
	print([[
<div class="chapter" id="header">
<img width="128" height="128" alt="luatcc" src="luatcc.png"/>
<p>Inline C for the Lua language</p>
<p class="bar">
<a href="]]..file_index..[[">home</a> &middot;
<a href="]]..file_index..[[#download">download</a> &middot;
<a href="]]..file_index..[[#installation">installation</a> &middot;
<a href="]]..file_index..[[#manual">manual</a>
</p>
</div>
]])
end

function footer()
	print([[
<div class="chapter" id="footer">
<small>Last update: ]]..os.date"%Y-%m-%d %H:%M:%S %Z"..[[</small>
</div>
]])
	print[[
</body>
</html>
]]
end

local chapterid = 0

function chapter(title, text, sections, raw)
	chapterid = chapterid+1
	local text = text:gsub("%%chapterid%%", tostring(chapterid))
	if not raw then
		text = markdown(text)
	end
	if sections then
		for _,section in ipairs(sections) do
			section = section:gsub("%%chapterid%%", tostring(chapterid))
			text = text..[[
<div class="section">
]]..markdown(section)..[[
</div>]]
		end
	end
	print([[
<div class="chapter">
<h1>]]..tostring(chapterid).." - "..title..[[</h1>
]]..text..[[
</div>
]])
end

function chapterp(title, text) chapter(title, "<p>"..text.."</p>") end

------------------------------------------------------------------------------

io.output(file_index)

header()

chapter("About Luatcc", [[
Luatcc is a Lua binding for libtcc, which is the core library of [TCC, the
Tiny C Compiler](http://fabrice.bellard.free.fr/tcc/). Primary goal of this
module is to be an illustration for the Gem *Interpreted C Modules* from the
book [Lua Programming Gems](http://www.lua.org/gems/). As this module may be
of interest independently from the book, I made it available here.

Luatcc features a module loader that allows to load C modules directly from
sources. To activate the loader you just have to load the tcc.loader module,
which will install itself in Lua 5.1 package system.

libtcc binding is not complete. Only the functions necessary to implement the
C source module loader have been bound. Also it is very low level (it maps
directly to libtcc C API). However I'm open to suggestions or requests to add
more bindings or to implement a higher level interface in the future. Just ask
:-)

## Support

All support is done through the [Lua mailing list](http://www.lua.org/lua-l.html).
If the traffic becomes too important a specialized mailing list will be
created.

Feel free to ask for further developments. I can't guarantee that I'll develop
everything you ask, but as this module currently exists only for pedagogical
purpose and is not actually used there is very little chance that I develop it
anymore if you don't ask me to.

## Credits

This module is written and maintained by [Jérôme Vuarand](mailto:jerome.vuarand@gmail.com).
It is originally based on [lua-tcc](http://luaforge.net/projects/lua-tcc/)
module by Javier Guerra and has been extended to support a bigger part of
libtcc API and to work as a Lua module loader.

This website and Luatcc downloadable packages are generously hosted by
[Luaforge.net](http://luaforge.net/). Consider making a donation.

Luatcc is available under a [MIT-style license](LICENSE.txt).
]])

chapter('<a name="download">Download</a>', [[
Luatcc sources are available in its Mercurial repository:

    hg clone http://piratery.net/hg/luatcc/

Tarballs of the latest code can be downloaded directly from there: as
[gz](http://piratery.net/hg/luatcc/archive/tip.tar.gz),
[bz2](http://piratery.net/hg/luatcc/archive/tip.tar.bz2) or
[zip](http://piratery.net/hg/luatcc/archive/tip.zip).

Alternatively Luatcc is available on its [Luaforge project page](http://luaforge.net/frs/?group_id=255).
]])

chapter('<a name="installation">Installation</a>', [[
## Build instructions

To build Luatcc edit Makefile to configure the install directories and
options, then run make in the top directory:

    $ vi Makefile
    $ make
    $ make test
    $ make install

## TCC

To use Luatcc you need TCC. The recommended version is 0.9.25. Luatcc does
work with 0.9.24 and 0.9.23, but you need to uncomment a line in the Makefile
because there is no way to detect the 0.9.25 API change automatically. TCC is
available at:

- [http://bellard.org/tcc/](http://bellard.org/tcc/)

##Testing the module

In the test subdirectory you will find some test programs to check that
everything is working properly. They are run by the "make test" target,
look at each testx.lua file to have an idea of what each test does.
]])

local functions = { {
	name = "functions";
	title = "Module functions";
	doc = "These functions are global to the module.";
	functions = { {
		name = "tcc.new";
		parameters = {};
		doc = [[
Returns a new TCC compiling context. This context can be used to compile C code and dynamically execute it.
<pre>
     local context = tcc.new()
</pre>
]];
	}
} }, {
	name = "context_methods";
	title = "Context methods";
	doc = "These functions are the method of the compiler context returned by <code>tcc.new</code>.";
	functions = { {
		name = "context:add_include_path";
		parameters = {"path"};
		doc = [[Adds an include path to the context. <code>#include</code> directives in compiled sources will look for header files in paths provided by that function and some system-wide paths defined when compiling TCC.]];
	},{
		name = "context:compile";
		parameters = {"source [", "chunkname]"};
		doc = [=[Compiles a C source file inside the context. Optionnal <code>chunkname</code> argument can be a string that will be displayed in error messages (typically it will be the source file from which <code>source</code> is extracted, if any).
<pre>
     context:compile[[
          #include &lt;lua.h&gt;
          int hello(lua_State* L)
          {
               lua_pushstring(L, "Hello World!");
               return 1;
          }
     ]]
</pre>
]=];
	},{
		name = "context:add_library_path";
		parameters = {"path"};
		doc = [[Adds a library path to the context. <code>context:add_library</code> will look for libraries in the paths provided by that function and in some system-wide paths defined when compiling TCC.]];
	},{
		name = "context:add_library";
		parameters = {"libraryname"};
		doc = [[Adds a library to the context. This can be used to load static libraries or import libraries for dynamically loaded libraries. <code>libraryname</code> is the short name of the library (for example short name of liblua51.a is <code>"lua51"</code>).]];
	},{
		name = "context:relocate";
		parameters = {};
		doc = [[Performs the actual linking of the compiled sources and libraries present in the context. This function returns nothing, to access externally accessible symbols from the linked code use <code>context:get_symbol</code>.
<pre>
     context:relocate()
</pre>
]];
	},{
		name = "context:get_symbol";
		parameters = {"symbolname"};
		doc = [[This function looks for a symbol in the compiled code present in the context. The symbol is cast to a ]]..manclink('lua_CFunction')..[[, and returned as a <code>function</code>. You have to make sure that the symbol matches ]]..manclink('lua_CFunction')..[[, otherwise calling the returned function has unexpected behaviour (which is likely to be a crash).
<pre>
     local hello = context:get_symbol("hello")
     print(hello()) -- Should output "Hello World!"
</pre>
]];
	}
} }, {
	name = "module_loader";
	title = "C source module loader";
	doc = [[
	<p>Luatcc features a new module loader. That loader will load C modules directly from source files. To activate the loader, you juste have to load the <code>tcc.loader</code> submodule:
<pre>
     require("tcc.loader")
</pre>
Loading the <code>tcc.loader</code> submodule automatically installs the loader in Lua package system. Any further call to <code>require</code> will use the loader.</p>

	<p>The C source module loader looks for C source files according to the path in <code>package.tccpath</code>, which default value is <code>"./?.c"</code>. Just like for ]]..manlink('package.path')..[[ and ]]..manlink('package.cpath')..[[, the interrogation marks will be replaced with the module name, in which all dots have been replaced with a "directory separator" (such as "<code>/</code>" in Unix).</p>

	<p>Error reporting is done the same way than with the predefined module loaders. Also the C source module loader has the lowest priority, it is invoked last if no other loader can locate a module. To change loader priority you have to manually alter the <code>package.loaders</code> table.</p>
]];
	functions = {};
} }

local funcstr = ""
for sectionid,section in ipairs(functions) do
	funcstr = funcstr..[[
	<div class="section">
	<h2><a name="]]..section.name..[[">%chapterid%.]]..tostring(sectionid).." - "..section.title..[[</a></h2>
]]..section.doc..[[
]]
	for _,func in ipairs(section.functions) do
		funcstr = funcstr..[[
		<div class="function">
		<h3><a name="]]..func.name..[["><code>]]..func.name..' ('..table.concat(func.parameters, ", ")..[[)</code></a></h3>
		<p>]]..func.doc..[[</p>
		</div>
]]
	end
	funcstr = funcstr..[[
	</div>
]]
end

chapter('<a name="manual">Manual</a>', [[
<p>Here you can find a list of the functions present in the module and how to use them. Luatcc main module follows Lua 5.1 package system, see the <a href="http://www.lua.org/manual/5.1/">Lua 5.1 manual</a> for further explanations.</p>
]]..funcstr, nil, true)

footer()

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
