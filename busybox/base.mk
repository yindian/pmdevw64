EXE = busybox.exe
SOURCE = source/$(ARCH)
SRCDIR = busybox-w32
SRCURL = https://frippery.org/files/busybox/$(SRCFILE)
SRCFILE = busybox-w32-FRP-5579-g5749feb35.tgz
SRCMD5 = 4555bc7c8f23fa495d0aeaee9b6ff8c6
PATCHES = patch_alt_cp_ts.diff
PATCHES += patch_old_mingw_32.diff
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
	rm -rf $(SOURCE) $(OUTPUTDIR)/$(EXE)

$(OUTPUTDIR)/$(EXE): $(SOURCE)/$(SRCDIR)/$(EXE)
	@mkdir -p $(@D)
	cp -p $< $@

$(SOURCE)/$(SRCDIR)/$(EXE): $(SOURCE)/$(SRCDIR)/.config $(SOURCE)/$(SRCDIR)/Makefile
	$(MAKE) -C $(SOURCE)/$(SRCDIR)

$(SOURCE)/$(SRCDIR)/Makefile: $(SOURCEDIR)/$(SRCFILE)
	@mkdir -p $(SOURCE)
	tar -C $(SOURCE) -xzf $<
	for c in $(PATCHES); do cat $$c | (cd $(@D); patch -p1); done
	touch -r $@ $<
ifeq ($(SED),gsed)
	$(SED) -i 's/\bsed\b/gsed/g' $@
	find $(SOURCE)/$(SRCDIR)/scripts -type f | xargs $(SED) -i 's/\bsed\b/gsed/g'
endif

$(SOURCE)/$(SRCDIR)/.config: $(CONFIG) $(SOURCE)/$(SRCDIR)/Makefile
ifeq ($(ARCH),x86)
	$(MAKE) -C $(SOURCE)/$(SRCDIR) mingw32_defconfig
else
ifeq ($(ARCH),x64)
	$(MAKE) -C $(SOURCE)/$(SRCDIR) mingw64_defconfig
else
	$(MAKE) -C $(SOURCE)/$(SRCDIR) mingw64a_defconfig
endif
endif
	$(SED) -i '$(call config_to_sed, $<)' $@

$(SOURCEDIR)/$(SRCFILE):
	@mkdir -p $(@D)
	curl -RL $(SRCURL) -o $@ || (rm -f $@; exit 1)
	[ "$$(md5sum $@ | awk '{print $$1}')" = $(SRCMD5) ] ||(rm -f $@; exit 1)
