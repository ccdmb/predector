BUILD_IMAGE="condaforge/linux-anvil-comp7:latest"
CONTAINER=1
DOCKER=docker
ANACONDA_USER=predector

RVERSIONS=3.5 3.6 4.1
RTARGETS=r-deepredeff/0.1.1 r-effectr/1.0.2
RTARGETS_VERSIONS=$(foreach rversion,$(RVERSIONS),$(addprefix r-$(rversion)/,$(RTARGETS)))

TARGETS=effectorp1/1.0 effectorp2/2.0 effectorp3/3.0 localizer/1.0.4 apoplastp/1.0.1 deepsig/0f1e1d9 \
		signalp3/3.0b signalp4/4.1g signalp5/5.0b signalp6/6.0d \
		targetp2/2.0 lasagne/0.2.dev1 deeploc/1.0 \
		tmhmm/2.0c phobius/1.01 $(RTARGETS_VERSIONS)


r: $(addprefix targets/, $(RTARGETS_VERSIONS))

all: $(addprefix targets/,$(TARGETS))

clean:
	rm -rf -- targets builds

define RTEMPLATE
	@mkdir -p "$(dir $@)"
	@mkdir -p builds
	conda build \
	  --output-folder "builds" \
	  --keep-going \
          --user $(ANACONDA_USER) \
	  --R $(1) \
	  --channel conda-forge \
	  --channel bioconda \
	  --channel "file://${PWD}/builds" \
	  --channel "$(ANACONDA_USER)" \
	  "$(dir $<)"
endef

define RCONTAINERTEMPLATE
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
            --user $(ANACONDA_USER) \
	    --R $(1) \
	    --channel conda-forge \
	    --channel bioconda \
	    --channel "$(ANACONDA_USER)" \
	    "/work/$(dir $<)"

	touch $@
endef


targets/deeploc/1.0: targets/lasagne/0.2.dev1

ifeq ($(CONTAINER), 0)
targets/%: recipes/%/*
	@mkdir -p "$(dir $@)"
	@mkdir -p builds
	conda build \
	  --output-folder "builds" \
	  --keep-going \
          --user $(ANACONDA_USER) \
	  --channel conda-forge \
	  --channel bioconda \
	  --channel "file://${PWD}/builds" \
	  --channel "$(ANACONDA_USER)" \
	  "$(dir $<)"

	touch $@

targets/r-3.5/%: recipes/%/*
	$(call RTEMPLATE,3.5)

targets/r-3.6/%: recipes/%/*
	$(call RTEMPLATE,3.6)

targets/r-4.1/%: recipes/%/*
	$(call RTEMPLATE,4.1)

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
            --user $(ANACONDA_USER) \
	    --channel conda-forge \
	    --channel bioconda \
	    --channel "$(ANACONDA_USER)" \
	    "/work/$(dir $<)"

	touch $@

targets/r-3.5/%: recipes/%/*
	$(call RCONTAINERTEMPLATE,3.5)

targets/r-3.6/%: recipes/%/*
	$(call RCONTAINERTEMPLATE,3.6)

targets/r-4.1/%: recipes/%/*
	$(call RCONTAINERTEMPLATE,4.1)
endif


upload:
	mkdir -p builds/linux-64 builds/noarch
	anaconda upload \
	  --user $(ANACONDA_USER) \
	  --skip-existing \
	  $(shell find builds/linux-64 -name "*.tar.bz2") $(shell find builds/noarch -name "*.tar.bz2")
