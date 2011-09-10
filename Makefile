# Installation directory
INSTALL_TOP_SHARE=/usr/local/share/lua/5.1
INSTALL_TOP_LIB=/usr/local/lib/lua/5.1

# Module name
MODULE=tcc
DLL=$(MODULE).so

# If your libtcc does contain tcc_compile_named_string comment next line.
CPPFLAGS+=-D'tcc_compile_named_string(tcc,code,chunkname)=tcc_compile_string(tcc,code)'

# If you want to use TCC 0.9.23 or 0.9.24 uncomment following line
#CPPFLAGS+=-DUSE_TCC_0_9_23

##############################################################################
# /!\ You shouldn't have to change anything below

SRC=src/luatcc.c
CFLAGS+=-O2 -Wall
CPPFLAGS+=-Dluaopen_module=luaopen_$(MODULE) -DMODULE_API=extern
LDLIBS+=-ltcc -lc

build:src/$(DLL)

src/$(DLL):$(patsubst %.c,%.o,$(SRC))
	$(CC) $(LDFLAGS) -shared -o $@ $^ $(LDLIBS)

clean:
	rm -f src/$(DLL) $(patsubst %.c,%.o,$(SRC))

test:build
	$(MAKE) -C test

install:build
	mkdir -p $(INSTALL_TOP_LIB)
	cp src/$(DLL) $(INSTALL_TOP_LIB)
	mkdir -p $(INSTALL_TOP_SHARE)/$(MODULE)
	cp src/tcc/loader.lua $(INSTALL_TOP_SHARE)/$(MODULE)

uninstall:
	rm -f $(INSTALL_TOP_LIB)/$(DLL)
	rm -f $(INSTALL_TOP_SHARE)/$(MODULE)/loader.lua

.PHONY:build clean install uninstall test

# Copyright (c) 2009-2010 Jérôme Vuarand
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
