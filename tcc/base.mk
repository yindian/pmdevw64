EXE = tcc.exe
DSTDIR = tcc
SRCDIR = tcc
SRCURL = http://download.savannah.gnu.org/releases/tinycc/$(SRCFILE)
SRCFILE = tcc-0.9.27-win64-bin.zip
SRCMD5 = d73cf66cec8c761de38c7a3d16c9eb0d

.PHONY: clean

all: $(OUTPUTDIR)/$(DSTDIR)/$(EXE)

clean:
	rm -rf source $(OUTPUTDIR)/$(DSTDIR)

$(OUTPUTDIR)/$(DSTDIR)/$(EXE): $(SOURCEDIR)/$(SRCFILE)
	unzip -o $< -d $(OUTPUTDIR)
	touch -r $@ $<

$(SOURCEDIR)/$(SRCFILE):
	@mkdir -p $(@D)
	curl -RL $(SRCURL) -o $@ || (rm -f $@; exit 1)
	[ "$$(md5sum $@ | awk '{print $$1}')" = $(SRCMD5) ] ||(rm -f $@; exit 1)
