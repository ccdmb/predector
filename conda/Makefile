ANACONDA_USER=predector

TARGETS=ffindex/0.9.9.9 effectorp1/1.0 effectorp2/2.0 localizer/1.0.4 apoplastp/1.0.1 deepsig/0f1e1d9 \
		signalp3/3.0 signalp4/4.1g signalp5/5.0b \
		targetp2/2.0 lasagne/0.2.dev1 deeploc/1.0

all: $(addprefix targets/,$(TARGETS))

clean:
	rm -rf -- targets builds

targets/%: recipes/%/*
	@mkdir -p "$(dir $@)"
	@mkdir -p builds
	conda build \
	  --skip-existing \
	  --output-folder "builds" \
	  --keep-going \
	  --channel bioconda \
	  --channel conda-forge \
	  --channel "file://$(PWD)/builds" \
	  --channel "$(ANACONDA_USER)" \
	  "$(dir $<)"

	touch $@

upload:
	mkdir -p builds/linux-64 builds/noarch
	anaconda upload \
	  --user $(ANACONDA_USER) \
	  --skip-existing \
	  $(shell find builds/linux-64 -name "*.tar.bz2") $(shell find builds/noarch -name "*.tar.bz2")
