EXE = jq.exe
SRCDIR = .
SRCURL = https://github.com/stedolan/jq/releases/download/jq-1.4/$(SRCFILE)
SRCFILE = jq-win32.exe
SRCMD5 = a5342bab6db36e9d4e0116745a7568b6

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
