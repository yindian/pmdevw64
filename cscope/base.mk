EXE = cscope.exe
SRCDIR = cscope-15.9/src
SRCURL = https://downloads.sourceforge.net/project/cscope/cscope/v15.9/$(SRCFILE)
SRCFILE = cscope-15.9.tar.gz
SRCMD5 = 16f3cce078b6c0e42299def4028eea6f
PDCURSES = PDCurses-3.8
EXTRASRCURLS = https://downloads.sourceforge.net/project/pdcurses/pdcurses/3.8/$(PDCURSES).tar.gz
REGEX = regex-alpha3.8p1
EXTRASRCURLS += https://github.com/garyhouston/regex/archive/alpha3.8p1.tar.gz
EXTRASRCFILES = $(PDCURSES).tar.gz $(REGEX).tar.gz
PATCHES = cscope-win32.patch
ifneq ($(shell which gsed 2>/dev/null),)
SED = gsed
else
SED = sed
endif

.PHONY: clean

all: $(OUTPUTDIR)/$(EXE)

clean:
	rm -rf source $(OUTPUTDIR)/$(EXE)

$(OUTPUTDIR)/$(EXE): source/$(SRCDIR)/$(EXE)
	@mkdir -p $(@D)
	cp -p $< $@

source/$(SRCDIR)/$(EXE): source/$(SRCDIR)/Makefile
	$(MAKE) -j1 -C source/$(REGEX) CC=$(CROSSHOST)-gcc AR=$(CROSSHOST)-ar\
		CFLAGS="-I. -DPOSIX_MISTAKE -O2" lib
	$(MAKE) -C source/$(PDCURSES)/wincon CC=$(CROSSHOST)-gcc \
		AR=$(CROSSHOST)-ar STRIP=$(CROSSHOST)-strip \
		LINK=$(CROSSHOST)-gcc
	$(MAKE) -C $(<D) CC=$(CROSSHOST)-gcc STRIP=$(CROSSHOST)-strip
	$(CROSSHOST)-strip -p $@

source/$(SRCDIR)/Makefile: $(SOURCEDIR)/$(SRCFILE)
	@mkdir -p source
	for c in $(EXTRASRCFILES); do tar -C source -xzf $(SOURCEDIR)/$$c; done
	$(SED) -i 's/\<ar\>/$$(AR)/g' source/$(REGEX)/Makefile
	tar -C source -xzf $<
	for c in $(PATCHES); do cat $$c | (cd $(@D); patch -p2); done

$(SOURCEDIR)/$(SRCFILE):
	@mkdir -p $(@D)
	for c in $(EXTRASRCURLS); do (cd $(SOURCEDIR); curl -ROJL $$c ); done
	curl -RL $(SRCURL) -o $@ || (rm -f $@; exit 1)
	[ "$$(md5sum $@ | awk '{print $$1}')" = $(SRCMD5) ] ||(rm -f $@; exit 1)
