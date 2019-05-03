EXE = lua.exe
SRCDIR = lua-5.2.4/src
SRCURL = http://www.lua.org/ftp/$(SRCFILE)
SRCFILE = lua-5.2.4.tar.gz
SRCMD5 = 913fdb32207046b273fdb17aad70be13

.PHONY: clean

all: $(OUTPUTDIR)/$(EXE)

clean:
	rm -rf source $(OUTPUTDIR)/$(EXE)

$(OUTPUTDIR)/$(EXE): source/$(SRCDIR)/$(EXE)
	@mkdir -p $(@D)
	cp -p $< $@
	$(CROSSHOST)-strip -p $@

source/$(SRCDIR)/$(EXE): source/$(SRCDIR)/Makefile
	$(MAKE) -C $(<D) LUA_T=$(EXE) CC=$(CROSSHOST)-gcc \
		AR="$(CROSSHOST)-ar rcu" RANLIB=$(CROSSHOST)-ranlib $(EXE)

source/$(SRCDIR)/Makefile: $(SOURCEDIR)/$(SRCFILE)
	@mkdir -p source
	tar -C source -xzf $<

$(SOURCEDIR)/$(SRCFILE):
	@mkdir -p $(@D)
	curl -RL $(SRCURL) -o $@ || (rm -f $@; exit 1)
	[ "$$(md5sum $@ | awk '{print $$1}')" = $(SRCMD5) ] ||(rm -f $@; exit 1)
