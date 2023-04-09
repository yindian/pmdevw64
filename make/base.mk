EXE = make.exe
SOURCE = source/$(ARCH)
SRCDIR = make-4.2.1
SRCURL = https://ftp.gnu.org/gnu/make/$(SRCFILE)
SRCFILE = make-4.2.1.tar.bz2
SRCMD5 = 15b012617e7c44c0ed482721629577ac 
PATCHES = make-getopt.patch make-linebuf-mingw.patch
PATCHES += make-4.2.1-busybox-sh.patch

.PHONY: clean

all: $(OUTPUTDIR)/$(EXE)

clean:
	rm -rf $(SOURCE) $(OUTPUTDIR)/$(EXE)

$(OUTPUTDIR)/$(EXE): $(SOURCE)/$(SRCDIR)/$(EXE)
	@mkdir -p $(@D)
	cp -p $< $@

$(SOURCE)/$(SRCDIR)/$(EXE): $(SOURCE)/$(SRCDIR)/Makefile
	$(MAKE) -C $(SOURCE)/$(SRCDIR)
	$(CROSSHOST)-strip -p $@

$(SOURCE)/$(SRCDIR)/Makefile: $(SOURCEDIR)/$(SRCFILE)
	@mkdir -p $(SOURCE)
	tar -C $(SOURCE) -xjf $<
	for c in $(PATCHES); do cat $$c | (cd $(@D); patch -p1); done
	(cd $(@D); ./configure --host=$(CROSSHOST) --without-libintl-prefix \
		--without-libiconv-prefix ac_cv_dos_paths=yes )

$(SOURCEDIR)/$(SRCFILE):
	@mkdir -p $(@D)
	curl -RL $(SRCURL) -o $@ || (rm -f $@; exit 1)
	[ "$$(md5sum $@ | awk '{print $$1}')" = $(SRCMD5) ] ||(rm -f $@; exit 1)
