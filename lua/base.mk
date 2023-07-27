EXE = lua.exe
SOURCE = source/$(ARCH)
SRCDIR = lua-5.2.4/src
SRCURL = http://www.lua.org/ftp/$(SRCFILE)
SRCFILE = lua-5.2.4.tar.gz
SRCMD5 = 913fdb32207046b273fdb17aad70be13

.PHONY: clean

all: $(OUTPUTDIR)/$(EXE)

clean:
	rm -rf $(SOURCE) $(OUTPUTDIR)/$(EXE)

$(OUTPUTDIR)/$(EXE): $(SOURCE)/$(SRCDIR)/$(EXE)
	@mkdir -p $(@D)
	cp -p $< $@

$(SOURCE)/$(SRCDIR)/$(EXE): $(SOURCE)/$(SRCDIR)/Makefile
	$(MAKE) -C $(<D) LUA_T=$(EXE) CC=$(CROSSHOST)-gcc \
		AR="$(CROSSHOST)-ar rcu" RANLIB=$(CROSSHOST)-ranlib $(EXE)
	$(CROSSHOST)-strip -p $@ || $(CROSSHOST)-strip $@

$(SOURCE)/$(SRCDIR)/Makefile: $(SOURCEDIR)/$(SRCFILE)
	@mkdir -p $(SOURCE)
	tar -C $(SOURCE) -xzf $<
	touch -r $@ $<

$(SOURCEDIR)/$(SRCFILE):
	@mkdir -p $(@D)
	curl -RL $(SRCURL) -o $@ || (rm -f $@; exit 1)
	[ "$$(md5sum $@ | awk '{print $$1}')" = $(SRCMD5) ] ||(rm -f $@; exit 1)
