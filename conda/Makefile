BUILD_IMAGE="condaforge/linux-anvil-comp7:latest"
CONTAINER=1
DOCKER=podman
ANACONDA_USER=predector

TARGETS=effectorp1/1.0 effectorp2/2.0 localizer/1.0.4 apoplastp/1.0.1 deepsig/0f1e1d9 \
		signalp3/3.0b signalp4/4.1g signalp5/5.0b \
		targetp2/2.0 lasagne/0.2.dev1 deeploc/1.0 \
		tmhmm/2.0c phobius/1.01

all: $(addprefix targets/,$(TARGETS))

clean:
	rm -rf -- targets builds


targets/deeploc/1.0: targets/lasagne/0.2.dev1

ifeq ($(CONTAINER), 0)
targets/%: recipes/%/*
	@mkdir -p "$(dir $@)"
	@mkdir -p builds
	conda build \
	  --skip-existing \
	  --output-folder "builds" \
	  --keep-going \
	  --channel bioconda \
	  --channel conda-forge \
	  --channel "file://${PWD}/builds" \
	  --channel "$(ANACONDA_USER)" \
	  "$(dir $<)"

	touch $@
else
targets/%: recipes/%/*
	@mkdir -p "$(dir $@)"
	@mkdir -p builds
	chmod a+w builds
	$(DOCKER) run \
	  --rm \
	  -v "${PWD}:/work:z" \
	  -w "/work" \
	  $(BUILD_IMAGE) \
	  conda build \
	    --skip-existing \
	    --output-folder "/work/builds" \
	    --keep-going \
	    --channel bioconda \
	    --channel conda-forge \
	    --channel "$(ANACONDA_USER)" \
	    "/work/$(dir $<)"

	touch $@
endif


upload:
	mkdir -p builds/linux-64 builds/noarch
	anaconda upload \
	  --user $(ANACONDA_USER) \
	  --skip-existing \
	  $(shell find builds/linux-64 -name "*.tar.bz2") $(shell find builds/noarch -name "*.tar.bz2")
