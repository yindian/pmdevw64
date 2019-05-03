EXE = busybox.exe
SRCDIR = busybox-w32
SRCURL = https://frippery.org/files/busybox/$(SRCFILE)
SRCFILE = busybox-w32-FRP-3128-g241d4d4ac.tgz
SRCMD5 = f9d107e52b6174ba7c9024c2d3c941f6
PATCHES = patch_alt_cp_ts.diff
CONFIG = config

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

source/$(SRCDIR)/.config: $(CONFIG) source/$(SRCDIR)/Makefile
	cp -p $< $@
	$(MAKE) -C source/$(SRCDIR) oldconfig

$(SOURCEDIR)/$(SRCFILE):
	@mkdir -p $(@D)
	curl -RL $(SRCURL) -o $@ || (rm -f $@; exit 1)
	[ "$$(md5sum $@ | awk '{print $$1}')" = $(SRCMD5) ] ||(rm -f $@; exit 1)
