.PHONY:all
all:test5_mod.so

test5_mod.so:test5_mod.o
	$(LD) $(LDFLAGS) -shared -o $@ $< $(LDLIBS)
