EXE = busybox.exe
SOURCE = source/$(ARCH)
SRCDIR = busybox-w32
SRCURL = https://frippery.org/files/busybox/$(SRCFILE)
SRCFILE = busybox-w32-FRP-5007-g82accfc19.tgz
SRCMD5 = 430498acf892f2ca896278b7333a5746
PATCHES = patch_alt_cp_ts.diff
ifneq ($(shell $(CROSSHOST)-gcc -v 2>&1 | grep clang),)
PATCHES += patch_clang.diff
endif
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
	$(SED) 's/^\(CONFIG_CROSS_COMPILER_PREFIX\)=.*/\1="$(CROSSHOST)-"/' $(SOURCE)/$(SRCDIR)/configs/mingw64_defconfig > $(SOURCE)/$(SRCDIR)/configs/mingw$(ARCH)_defconfig 
	$(MAKE) -C $(SOURCE)/$(SRCDIR) mingw$(ARCH)_defconfig
endif
endif
	$(SED) -i '$(call config_to_sed, $<)' $@

$(SOURCEDIR)/$(SRCFILE):
	@mkdir -p $(@D)
	curl -RL $(SRCURL) -o $@ || (rm -f $@; exit 1)
	[ "$$(md5sum $@ | awk '{print $$1}')" = $(SRCMD5) ] ||(rm -f $@; exit 1)
