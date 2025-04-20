EXE = jq.exe
SRCDIR = $(ARCH)
SRCURL = https://github.com/stedolan/jq/releases/download/jq-1.4/$(SRCFILE)
SRCFILE = $(SRCFILE_$(ARCH))
SRCMD5 = $(SRCMD5_$(ARCH))
SRCFILE_x64 = jq-win64.exe
SRCMD5_x64 = 223c9a13fd8fd70b844bdb6be3ea9200
SRCFILE_x86 = jq-win32.exe
SRCMD5_x86 = a5342bab6db36e9d4e0116745a7568b6
SRCFILE_arm64 = $(SRCFILE_x64)
SRCMD5_arm64 = $(SRCMD5_x64)

.PHONY: clean

all: $(OUTPUTDIR)/$(EXE)

clean:
	rm -rf source $(OUTPUTDIR)/$(EXE)

$(OUTPUTDIR)/$(EXE): source/$(SRCDIR)/$(EXE)
	@mkdir -p $(@D)
	cp -p $< $@

source/$(SRCDIR)/$(EXE): $(SOURCEDIR)/$(SRCFILE)
	@mkdir -p $(@D)
	cp -p $< $@

$(SOURCEDIR)/$(SRCFILE):
	@mkdir -p $(@D)
	curl -RL $(SRCURL) -o $@ || (rm -f $@; exit 1)
	[ "$$(md5sum $@ | awk '{print $$1}')" = $(SRCMD5) ] ||(rm -f $@; exit 1)
