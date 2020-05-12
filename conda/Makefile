ANACONDA_USER=predector

TARGETS=ffindex/0.9.9.9 weka36/3.6.12 weka38/3.8.1

all: $(addprefix targets/,$(TARGETS))

clean:
	rm -rf -- targets builds

targets/%: recipes/%/meta.yaml recipes/%/build.sh
	@mkdir -p "$(dir $@)"
	@mkdir -p builds
	conda build \
	  --skip-existing \
	  --output-folder "builds" \
	  --keep-going \
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
