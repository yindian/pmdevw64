EXE = tcc.exe
DSTDIR = tcc
SRCDIR = tcc
SRCURL = http://download.savannah.gnu.org/releases/tinycc/$(SRCFILE)
SRCFILE = $(SRCFILE_$(ARCH))
SRCMD5 = $(SRCMD5_$(ARCH))
SRCFILE_x64 = tcc-0.9.27-win64-bin.zip
SRCMD5_x64 = d73cf66cec8c761de38c7a3d16c9eb0d
SRCFILE_x86 = tcc-0.9.27-win32-bin.zip
SRCMD5_x86 = 5a3979bd5044b795547a4948a5625a12
SRCFILE_arm64 = $(SRCFILE_x64)
SRCMD5_arm64 = $(SRCMD5_x64)

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
