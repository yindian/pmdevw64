EXE = 7z.exe
SRCDIR = .
SRCURL = https://www.7-zip.org/a/$(SRCFILE)
SRCFILE = 7z1604.exe
SRCMD5 = da7db29e783780f3a581e6e0bf4c595d

.PHONY: clean

all: $(OUTPUTDIR)/$(EXE)

clean:
	rm -rf source $(OUTPUTDIR)/$(EXE) $(OUTPUTDIR)/$(EXE:.exe=.dll)

$(OUTPUTDIR)/$(EXE): source/$(SRCDIR)/$(EXE)
	@mkdir -p $(@D)
	cp -p $(<:.exe=.dll) $(@:.exe=.dll)
	cp -p $< $@

source/$(SRCDIR)/$(EXE): $(SOURCEDIR)/$(SRCFILE)
	@mkdir -p $(@D)
	cd $(@D); 7z x -aoa -bd $<
	touch -r $@ $<

$(SOURCEDIR)/$(SRCFILE):
	@mkdir -p $(@D)
	curl -RL $(SRCURL) -o $@ || (rm -f $@; exit 1)
	[ "$$(md5sum $@ | awk '{print $$1}')" = $(SRCMD5) ] ||(rm -f $@; exit 1)
