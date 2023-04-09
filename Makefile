ARCHES = x64 x86 arm64
CROSSHOST_x64 = x86_64-w64-mingw32
CROSSHOST_x86 = i686-w64-mingw32
CROSSHOST_arm64 = aarch64-w64-mingw32

NOARCH := $(foreach arch,$(ARCHES),$(if $(shell which $(CROSSHOST_$(arch))-gcc 2>/dev/null),,$(arch)))
ARCHES := $(filter-out $(NOARCH),$(ARCHES))
PROJROOT := $(patsubst %/,%,$(dir $(CURDIR)/$(lastword $(MAKEFILE_LIST))))

.PHONY: build clean release

all: build

.PHONY: $(addprefix build_,$(ARCHES)) $(addprefix clean_,$(ARCHES)) $(addprefix release_,$(ARCHES))
build: $(addprefix build_,$(ARCHES))
	@echo Build All Done.

clean: $(addprefix clean_,$(ARCHES))
	@echo Clean All Done.

release: $(addprefix release_,$(ARCHES))
	@echo Release All Done.

define ArchRule
$(2)_$(1):
	@echo Doing $(2) $(1)
	+$(MAKE) -f $(PROJROOT)/Makefile.single ARCH=$(1) CROSSHOST=$$(CROSSHOST_$(1)) PROJROOT=$(PROJROOT) SOURCEDIR=$(PROJROOT)/$(1)/source OUTPUTDIR=$(PROJROOT)/$(1)/pmdev RELEASE=pmdev-$(1)-bin.zip $(2)
endef

$(foreach arch,$(ARCHES),$(foreach target,build clean release,$(eval $(call ArchRule,$(arch),$(target)))))
