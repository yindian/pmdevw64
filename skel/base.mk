FILES = rename

.PHONY: clean

all: $(addprefix $(OUTPUTDIR)/,$(FILES))

clean:
	@:

$(addprefix $(OUTPUTDIR)/,$(FILES)): $(OUTPUTDIR)/%: %
	@mkdir -p $(@D)
	cp -p $< $@
