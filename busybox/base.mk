EXE = busybox.exe
SRCDIR = busybox-w32
SRCURL = https://frippery.org/files/busybox/$(SRCFILE)
SRCFILE = busybox-w32-FRP-3466-g53c09d0e1.tgz
SRCMD5 = ce2edea951bb643bbfae0fddc295b4f0
PATCHES = patch_alt_cp_ts.diff
CONFIG = config
ifneq ($(shell which gsed 2>/dev/null),)
SED = gsed
else
SED = sed
endif
config_to_sed = $(shell $(SED) 's|^\(CONFIG[^ =]*\) *=\(.*\)|/\\<\1\\>/s/.*/\1=\2/;|; s|^\# *\(CONFIG[^ =]*\)\(.*\)|/\\<\1\\>/s/.*/\# \1\2/;|' $(1))

.PHONY: clean

all: $(OUTPUTDIR)/$(EXE)

clean:
	rm -rf source $(OUTPUTDIR)/$(EXE)

$(OUTPUTDIR)/$(EXE): source/$(SRCDIR)/$(EXE)
	@mkdir -p $(@D)
	cp -p $< $@

source/$(SRCDIR)/$(EXE): source/$(SRCDIR)/.config source/$(SRCDIR)/Makefile
	$(MAKE) -C source/$(SRCDIR)

source/$(SRCDIR)/Makefile: $(SOURCEDIR)/$(SRCFILE)
	@mkdir -p source
	tar -C source -xzf $<
	for c in $(PATCHES); do cat $$c | (cd $(@D); patch -p1); done
	touch -r $@ $<
ifeq ($(SED),gsed)
	$(SED) -i 's/\bsed\b/gsed/g' $@
	find source/$(SRCDIR)/scripts -type f | xargs $(SED) -i 's/\bsed\b/gsed/g'
endif

source/$(SRCDIR)/.config: $(CONFIG) source/$(SRCDIR)/Makefile
	$(MAKE) -C source/$(SRCDIR) mingw64_defconfig
	$(SED) -i '$(call config_to_sed, $<)' $@

$(SOURCEDIR)/$(SRCFILE):
	@mkdir -p $(@D)
	curl -RL $(SRCURL) -o $@ || (rm -f $@; exit 1)
	[ "$$(md5sum $@ | awk '{print $$1}')" = $(SRCMD5) ] ||(rm -f $@; exit 1)
