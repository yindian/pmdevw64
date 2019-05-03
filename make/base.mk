EXE = make.exe
SRCDIR = make-4.2.1
SRCURL = https://ftp.gnu.org/gnu/make/$(SRCFILE)
SRCFILE = make-4.2.1.tar.bz2
SRCMD5 = 15b012617e7c44c0ed482721629577ac 
PATCHES = make-getopt.patch make-linebuf-mingw.patch
PATCHES += make-4.2.1-busybox-sh.patch

.PHONY: clean

all: $(OUTPUTDIR)/$(EXE)

clean:
	rm -rf source $(OUTPUTDIR)/$(EXE)

$(OUTPUTDIR)/$(EXE): source/$(SRCDIR)/$(EXE)
	@mkdir -p $(@D)
	cp -p $< $@

source/$(SRCDIR)/$(EXE): source/$(SRCDIR)/Makefile
	$(MAKE) -C source/$(SRCDIR)
	$(CROSSHOST)-strip -p $@

source/$(SRCDIR)/Makefile: $(SOURCEDIR)/$(SRCFILE)
	@mkdir -p source
	tar -C source -xjf $<
	for c in $(PATCHES); do cat $$c | (cd $(@D); patch -p1); done
	(cd $(@D); ./configure --host=$(CROSSHOST) --without-libintl-prefix \
		--without-libiconv-prefix ac_cv_dos_paths=yes )

$(SOURCEDIR)/$(SRCFILE):
	@mkdir -p $(@D)
	curl -RL $(SRCURL) -o $@ || (rm -f $@; exit 1)
	[ "$$(md5sum $@ | awk '{print $$1}')" = $(SRCMD5) ] ||(rm -f $@; exit 1)
