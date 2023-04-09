EXE = 7z.exe
SRCDIR = $(ARCH)
SRCURL = https://www.7-zip.org/a/$(SRCFILE)
SRCFILE = $(SRCFILE_$(ARCH))
SRCMD5 = $(SRCMD5_$(ARCH))
SRCFILE_x64 = 7z1604-x64.exe
SRCMD5_x64 = 04584f3aed5b27fd0ac2751b36273d94
SRCFILE_x86 = 7z1604.exe
SRCMD5_x86 = da7db29e783780f3a581e6e0bf4c595d
SRCFILE_arm64 = 7z2107-arm64.exe
SRCMD5_arm64 = da3dc49e9d58aa4e43d369a5b5fe7f46

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
