CROSSHOST ?= x86_64-w64-mingw32
PROJROOT := $(patsubst %/,%,$(dir $(CURDIR)/$(lastword $(MAKEFILE_LIST))))
SOURCEDIR = $(PROJROOT)/source
OUTPUTDIR = $(PROJROOT)/output
export CROSSHOST PROJROOT SOURCEDIR OUTPUTDIR

.PHONY: build clean

all: build

MKFN = base.mk
MODULES := $(patsubst $(PROJROOT)/%/$(MKFN),%,$(wildcard $(PROJROOT)/*/$(MKFN)))
MODULE_BUILDS = $(addprefix module_build_,$(filter-out $(DISABLE),$(MODULES)))
MODULE_CLEANS = $(addprefix module_clean_,$(filter-out $(DISABLE),$(MODULES)))
.PHONY: $(MODULE_BUILDS) $(MODULE_BUILDS)

build: $(MODULE_BUILDS)
	@echo Build Done.

clean: $(MODULE_CLEANS)
	rm -rf $(OUTPUTDIR)
	@echo Clean Done.

$(MODULE_BUILDS): module_build_%: $(PROJROOT)/%/$(MKFN)
	$(MAKE) -C $(<D) -f $<

$(MODULE_CLEANS): module_clean_%: $(PROJROOT)/%/$(MKFN)
	$(MAKE) -C $(<D) -f $< clean
