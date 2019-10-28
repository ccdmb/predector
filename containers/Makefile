PWD=$(shell pwd)
DEBIAN_VERSION=buster-20190812-slim
TAG=pannot-v0.0.1
MAINTAINER=Darcy Jones <darcy.ab.jones@gmail.com>
DOCKER_USER=darcyabjones
BASE_IMAGE=$(DOCKER_USER)/base:$(TAG)

INSTALL_BASE=/opt

define make_image_name
$(DOCKER_USER)/$(notdir $1):$(TAG)
endef

# SOFTWARE_VERSIONs

FFINDEX_TAG=0.9.9.9
FFINDEX_REPO=https://github.com/ahcm/ffindex.git
FFINDEX_PREFIX_ARG=$(INSTALL_BASE)/ffindex/$(FFINDEX_TAG)

MMSEQS_TAG=10-6d92c
MMSEQS_REPO=https://github.com/soedinglab/MMseqs2.git
MMSEQS_PREFIX_ARG=$(INSTALL_BASE)/mmseqs/$(MMSEQS_TAG)

SIGNALP3_VERSION=3.0
SIGNALP3_PREFIX_ARG=$(INSTALL_BASE)/signalp/$(SIGNALP3_VERSION)
SIGNALP3_TAR=sources/signalp-3.0.Linux.tar.Z

SIGNALP4_VERSION=4.1f
SIGNALP4_PREFIX_ARG=$(INSTALL_BASE)/signalp/$(SIGNALP4_VERSION)
SIGNALP4_TAR=sources/signalp-4.1f.Linux.tar.gz

SIGNALP5_VERSION=5.0
SIGNALP5_PREFIX_ARG=$(INSTALL_BASE)/signalp/$(SIGNALP5_VERSION)
SIGNALP5_TAR=sources/signalp-5.0.Linux.tar.gz

TMHMM_VERSION=2.0c
TMHMM_PREFIX_ARG=$(INSTALL_BASE)/tmhmm/$(TMHMM_VERSION)
TMHMM_TAR=sources/tmhmm-2.0c.Linux.tar.gz

PHOBIUS_VERSION=101
PHOBIUS_PREFIX_ARG=$(INSTALL_BASE)/phobius/$(PHOBIUS_VERSION)
PHOBIUS_TAR=sources/phobius101_linux.tar.gz

CHLOROP_VERSION=1.1
CHLOROP_PREFIX_ARG=$(INSTALL_BASE)/chlorop/$(CHLOROP_VERSION)
CHLOROP_TAR=sources/chlorop-1.1.Linux.tar.Z

TARGETP_VERSION=1.1b
TARGETP_PREFIX_ARG=$(INSTALL_BASE)/targetp/$(TARGETP_VERSION)
TARGETP_TAR=sources/targetp-1.1b.Linux.tar.Z

DEEPLOC_VERSION=1.0
DEEPLOC_PREFIX_ARG=$(INSTALL_BASE)/deeploc/$(DEEPLOC_VERSION)
DEEPLOC_TAR=sources/deeploc-1.0.All.tar.gz

DEEPSIG_COMMIT=69e01cb
DEEPSIG_PREFIX_ARG=$(INSTALL_BASE)/deepsig/$(DEEPSIG_COMMIT)
DEEPSIG_REPO=https://github.com/BolognaBiocomp/deepsig.git

TENSORFLOW_VERSION=1.5.0
TENSORFLOW_PREFIX_ARG=$(INSTALL_BASE)/tensorflow/$(TENSORFLOW_VERSION)

KERAS_VERSION=2.2.4
KERAS_PREFIX_ARG=$(INSTALL_BASE)/keras/$(KERAS_VERSION)


WEKA_38_VERSION=3.8.1
WEKA_38_URL=https://sourceforge.net/projects/weka/files/weka-3-8/3.8.1/weka-3-8-1.zip/download
WEKA_38_PREFIX_ARG=$(INSTALL_BASE)/weka/$(WEKA_38_VERSION)

WEKA_36_VERSION=3.6.12
WEKA_36_URL=https://sourceforge.net/projects/weka/files/weka-3-6/3.6.12/weka-3-6-12.zip/download
WEKA_36_PREFIX_ARG=$(INSTALL_BASE)/weka/$(WEKA_36_VERSION)

EMBOSS_VERSION=6.5.7
EMBOSS_URL=ftp://emboss.open-bio.org/pub/EMBOSS/old/6.5.0/EMBOSS-6.5.7.tar.gz
EMBOSS_PREFIX_ARG=$(INSTALL_BASE)/emboss/$(EMBOSS_VERSION)

EFFECTORP1_VERSION=1.0
EFFECTORP1_URL=http://effectorp.csiro.au/EffectorP_1.0.tar.gz
EFFECTORP1_PREFIX_ARG=$(INSTALL_BASE)/effectorp/$(EFFECTORP1_VERSION)

EFFECTORP2_VERSION=2.0
EFFECTORP2_URL=http://effectorp.csiro.au/EffectorP_2.0.tar.gz
EFFECTORP2_PREFIX_ARG=$(INSTALL_BASE)/effectorp/$(EFFECTORP2_VERSION)

LOCALIZER_VERSION=1.0.4
LOCALIZER_URL=http://localizer.csiro.au/LOCALIZER_1.0.4.tar.gz
LOCALIZER_PREFIX_ARG=$(INSTALL_BASE)/localizer/$(LOCALIZER_VERSION)

APOPLASTP_VERSION=1.0.1
APOPLASTP_URL=http://apoplastp.csiro.au/ApoplastP_1.0.1.tar.gz
APOPLASTP_PREFIX_ARG=$(INSTALL_BASE)/apoplastp/$(APOPLASTP_VERSION)

FFDB_TAG=ddbe321
FFDB_REPO=https://github.com/darcyabjones/ffdb.git
FFDB_PREFIX_ARG=$(INSTALL_BASE)/ffdb/$(FFDB_TAG)

GENERAL=base python3 deepsig ffdb emboss
PROPRIETARY=phobius signalp3 signalp4 signalp5 tmhmm targetp deeploc
SPERSCHNEIDER=effectorp1 effectorp2 localizer apoplastp


all: docker/all singularity/all

# Docker targets
docker: docker/pannot
	touch $@

docker/all: docker/general docker/sperschneider
	@echo "WARNING: proprietary software will not be built by default."
	@echo "WARNING: call 'make docker/proprietary' explicitly to create them."
	touch $@

docker/general: $(addprefix docker/,$(GENERAL))
	touch $@

docker/sperschneider: $(addprefix docker/,$(SPERSCHNEIDER))
	touch $@

docker/proprietary: $(addprefix docker/,$(PROPRIETARY))
	touch $@

# Singularity targets
singularity: singularity/pannot.sif
	touch $@

singularity/all: singularity/general singularity/sperschneider
	@echo "WARNING: proprietary software will not be built by default."
	@echo "WARNING: call make singularity/proprietary explicitly to create them."
	touch $@

singularity/general: $(addprefix singularity/,$(addsuffix .sif,$(GENERAL)))
	touch $@

singularity/sperschneider: $(addprefix singularity/,$(addsuffix .sif,$(SPERSCHNEIDER)))
	touch $@

singularity/proprietary: $(addprefix singularity/,$(addsuffix .sif,$(PROPRIETARY)))
	touch $@


# Pull containers from dockerhub
dockerpull: dockerpull/pannot
	touch docker/$(notdir $@)

dockerpull/all: dockerpull/general dockerpull/sperschneider
	touch docker/$(notdir $@)

dockerpull/general: $(addprefix dockerpull/,$(GENERAL))
	touch docker/$(notdir $@)

dockerpull/sperschneider: $(addprefix dockerpull/,$(SPERSCHNEIDER))
	touch docker/$(notdir $@)


clean:
	docker stop $(shell docker ps -aq) || true
	docker rm $(shell docker ps -a -q) || true
	docker rmi $(shell docker images -q) || true
	singularity cache clean --force
	rm -rf -- tmp
	rm -rf -- docker

tidy:
	# Just removes untagged images to free up space
	singularity cache clean --force
	docker image prune -f


# Generic rules
singularity/%.sif: docker/%
	@mkdir -p "$(dir $@)"
	@mkdir -p tmp tmp/cache
	SINGULARITY_TMPDIR="${PWD}/tmp" SINGULARITY_CACHEDIR="${PWD}/tmp/cache" singularity build \
	  --force \
	  --tmpdir "${PWD}/tmp" \
	  "$@" \
	  "docker-daemon://$(call make_image_name,$(notdir $(basename $@)))"

docker/%.tar.gz: docker/%
	@mkdir -p "$(dir $@)"
	docker save "$(call make_image_name,$(basename $(basename $@)))" | gzip > $@

dockerpull/%:
	docker pull "$(call make_image_name,$(notdir $@))"
	@mkdir -p "$(dir $@)"
	@touch docker/$(notdir $@)


docker/base: base.Dockerfile
	docker build \
	  --build-arg DEBIAN_VERSION="$(DEBIAN_VERSION)" \
	  --build-arg MAINTAINER="$(MAINTAINER)" \
	  --build-arg PIPELINE_VERSION="$(TAG)" \
	  --file $< \
	  -t "$(call make_image_name,$@)" \
	  .
	@mkdir -p "$(dir $@)"
	@touch $@


docker/python3: python3.Dockerfile docker/base
	docker build \
	  --build-arg IMAGE="$(BASE_IMAGE)" \
	  --file $< \
	  -t "$(call make_image_name,$@)" \
	  .
	@mkdir -p "$(dir $@)"
	@touch $@


docker/ffdb: ffdb.Dockerfile docker/base
	docker build \
	  --build-arg IMAGE="$(BASE_IMAGE)" \
	  --build-arg FFDB_TAG="$(FFDB_TAG)" \
	  --build-arg FFDB_REPO="$(FFDB_REPO)" \
	  --build-arg FFDB_PREFIX_ARG="$(FFDB_PREFIX_ARG)" \
	  --file $< \
	  -t "$(call make_image_name,$@)" \
	  .
	@mkdir -p "$(dir $@)"
	@touch $@


docker/ffindex: ffindex.Dockerfile docker/base docker/ffdb
	docker build \
	  --build-arg IMAGE="$(BASE_IMAGE)" \
	  --build-arg FFINDEX_TAG="$(FFINDEX_TAG)" \
	  --build-arg FFINDEX_REPO="$(FFINDEX_REPO)" \
	  --build-arg FFINDEX_PREFIX_ARG="$(FFINDEX_PREFIX_ARG)" \
	  --build-arg FFDB_IMAGE="$(call make_image_name,ffdb)" \
	  --build-arg FFDB_TAG="$(FFDB_TAG)" \
	  --build-arg FFDB_PREFIX_ARG="$(FFDB_PREFIX_ARG)" \
	  --file $< \
	  -t "$(call make_image_name,$@)" \
	  .
	@mkdir -p "$(dir $@)"
	@touch $@


docker/mmseqs: mmseqs.Dockerfile docker/base
	docker build \
	  --build-arg IMAGE="$(BASE_IMAGE)" \
	  --build-arg MMSEQS_TAG="$(MMSEQS_TAG)" \
	  --build-arg MMSEQS_REPO="$(MMSEQS_REPO)" \
	  --build-arg MMSEQS_PREFIX_ARG="$(MMSEQS_PREFIX_ARG)" \
	  --file $< \
	  -t "$(call make_image_name,$@)" \
	  .
	@mkdir -p "$(dir $@)"
	@touch $@


docker/signalp3: signalp3.Dockerfile docker/base docker/ffindex $(SIGNALP3_TAR)
	docker build \
	  --build-arg IMAGE="$(BASE_IMAGE)" \
	  --build-arg SIGNALP3_VERSION="$(SIGNALP3_VERSION)" \
	  --build-arg SIGNALP3_TAR="$(SIGNALP3_TAR)" \
	  --build-arg SIGNALP3_PREFIX_ARG="$(SIGNALP3_PREFIX_ARG)" \
	  --build-arg FFINDEX_IMAGE="$(call make_image_name,ffindex)" \
	  --build-arg FFINDEX_TAG="$(FFINDEX_TAG)" \
	  --build-arg FFINDEX_PREFIX_ARG="$(FFINDEX_PREFIX_ARG)" \
	  --file $< \
	  -t "$(call make_image_name,$@)" \
	  .
	@mkdir -p "$(dir $@)"
	@touch $@


docker/signalp4: signalp4.Dockerfile docker/base docker/ffindex $(SIGNALP4_TAR)
	docker build \
	  --build-arg IMAGE="$(BASE_IMAGE)" \
	  --build-arg SIGNALP4_VERSION="$(SIGNALP4_VERSION)" \
	  --build-arg SIGNALP4_TAR="$(SIGNALP4_TAR)" \
	  --build-arg SIGNALP4_PREFIX_ARG="$(SIGNALP4_PREFIX_ARG)" \
	  --build-arg FFINDEX_IMAGE="$(call make_image_name,ffindex)" \
	  --build-arg FFINDEX_TAG="$(FFINDEX_TAG)" \
	  --build-arg FFINDEX_PREFIX_ARG="$(FFINDEX_PREFIX_ARG)" \
	  --file $< \
	  -t "$(call make_image_name,$@)" \
	  .
	@mkdir -p "$(dir $@)"
	@touch $@


docker/signalp5: signalp5.Dockerfile docker/base docker/ffindex $(SIGNALP5_TAR)
	docker build \
	  --build-arg IMAGE="$(BASE_IMAGE)" \
	  --build-arg SIGNALP5_VERSION="$(SIGNALP5_VERSION)" \
	  --build-arg SIGNALP5_TAR="$(SIGNALP5_TAR)" \
	  --build-arg SIGNALP5_PREFIX_ARG="$(SIGNALP5_PREFIX_ARG)" \
	  --build-arg FFINDEX_IMAGE="$(call make_image_name,ffindex)" \
	  --build-arg FFINDEX_TAG="$(FFINDEX_TAG)" \
	  --build-arg FFINDEX_PREFIX_ARG="$(FFINDEX_PREFIX_ARG)" \
	  --file $< \
	  -t "$(call make_image_name,$@)" \
	  .
	@mkdir -p "$(dir $@)"
	@touch $@


docker/tmhmm: tmhmm.Dockerfile docker/base docker/ffindex $(TMHMM_TAR)
	docker build \
	  --build-arg IMAGE="$(BASE_IMAGE)" \
	  --build-arg TMHMM_VERSION="$(TMHMM_VERSION)" \
	  --build-arg TMHMM_TAR="$(TMHMM_TAR)" \
	  --build-arg TMHMM_PREFIX_ARG="$(TMHMM_PREFIX_ARG)" \
	  --build-arg FFINDEX_IMAGE="$(call make_image_name,ffindex)" \
	  --build-arg FFINDEX_TAG="$(FFINDEX_TAG)" \
	  --build-arg FFINDEX_PREFIX_ARG="$(FFINDEX_PREFIX_ARG)" \
	  --file $< \
	  -t "$(call make_image_name,$@)" \
	  .
	@mkdir -p "$(dir $@)"
	@touch $@


docker/targetp: targetp.Dockerfile docker/base docker/signalp3 docker/ffindex $(TARGETP_TAR)
	docker build \
	  --build-arg IMAGE="$(BASE_IMAGE)" \
	  --build-arg SIGNALP3_IMAGE="$(call make_image_name,signalp3)" \
	  --build-arg SIGNALP3_VERSION="$(SIGNALP3_VERSION)" \
	  --build-arg SIGNALP3_PREFIX_ARG="$(SIGNALP3_PREFIX_ARG)" \
	  --build-arg CHLOROP_VERSION="$(CHLOROP_VERSION)" \
	  --build-arg CHLOROP_TAR="$(CHLOROP_TAR)" \
	  --build-arg CHLOROP_PREFIX_ARG="$(CHLOROP_PREFIX_ARG)" \
	  --build-arg TARGETP_VERSION="$(TARGETP_VERSION)" \
	  --build-arg TARGETP_TAR="$(TARGETP_TAR)" \
	  --build-arg TARGETP_PREFIX_ARG="$(TARGETP_PREFIX_ARG)" \
	  --build-arg FFINDEX_IMAGE="$(call make_image_name,ffindex)" \
	  --build-arg FFINDEX_TAG="$(FFINDEX_TAG)" \
	  --build-arg FFINDEX_PREFIX_ARG="$(FFINDEX_PREFIX_ARG)" \
	  --file $< \
	  -t "$(call make_image_name,$@)" \
	  .
	@mkdir -p "$(dir $@)"
	@touch $@


docker/deeploc: deeploc.Dockerfile docker/base docker/ffindex $(DEEPLOC_TAR)
	docker build \
	  --build-arg IMAGE="$(BASE_IMAGE)" \
	  --build-arg DEEPLOC_VERSION="$(DEEPLOC_VERSION)" \
	  --build-arg DEEPLOC_TAR="$(DEEPLOC_TAR)" \
	  --build-arg DEEPLOC_PREFIX_ARG="$(DEEPLOC_PREFIX_ARG)" \
	  --build-arg FFINDEX_IMAGE="$(call make_image_name,ffindex)" \
	  --build-arg FFINDEX_TAG="$(FFINDEX_TAG)" \
	  --build-arg FFINDEX_PREFIX_ARG="$(FFINDEX_PREFIX_ARG)" \
	  --file $< \
	  -t "$(call make_image_name,$@)" \
	  .
	@mkdir -p "$(dir $@)"
	@touch $@


docker/deepsig: deepsig.Dockerfile docker/base docker/ffindex
	docker build \
	  --build-arg IMAGE="$(BASE_IMAGE)" \
	  --build-arg DEEPSIG_COMMIT="$(DEEPSIG_COMMIT)" \
	  --build-arg DEEPSIG_REPO="$(DEEPSIG_REPO)" \
	  --build-arg DEEPSIG_PREFIX_ARG="$(DEEPSIG_PREFIX_ARG)" \
	  --build-arg FFINDEX_IMAGE="$(call make_image_name,ffindex)" \
	  --build-arg FFINDEX_TAG="$(FFINDEX_TAG)" \
	  --build-arg FFINDEX_PREFIX_ARG="$(FFINDEX_PREFIX_ARG)" \
	  --build-arg TENSORFLOW_VERSION="$(TENSORFLOW_VERSION)" \
	  --build-arg TENSORFLOW_PREFIX_ARG="$(TENSORFLOW_PREFIX_ARG)" \
	  --build-arg KERAS_VERSION="$(KERAS_VERSION)" \
	  --build-arg KERAS_PREFIX_ARG="$(KERAS_PREFIX_ARG)" \
	  --file $< \
	  -t "$(call make_image_name,$@)" \
	  .
	@mkdir -p "$(dir $@)"
	@touch $@


docker/phobius: phobius.Dockerfile docker/base docker/ffindex $(PHOBIUS_TAR)
	docker build \
	  --build-arg IMAGE="$(BASE_IMAGE)" \
	  --build-arg PHOBIUS_VERSION="$(PHOBIUS_VERSION)" \
	  --build-arg PHOBIUS_TAR="$(PHOBIUS_TAR)" \
	  --build-arg PHOBIUS_PREFIX_ARG="$(PHOBIUS_PREFIX_ARG)" \
	  --build-arg FFINDEX_IMAGE="$(call make_image_name,ffindex)" \
	  --build-arg FFINDEX_TAG="$(FFINDEX_TAG)" \
	  --build-arg FFINDEX_PREFIX_ARG="$(FFINDEX_PREFIX_ARG)" \
	  --file $< \
	  -t "$(call make_image_name,$@)" \
	  .
	@mkdir -p "$(dir $@)"
	@touch $@


docker/weka38: weka.Dockerfile docker/base
	docker build \
	  --build-arg IMAGE="$(BASE_IMAGE)" \
	  --build-arg WEKA_VERSION="$(WEKA_38_VERSION)" \
	  --build-arg WEKA_URL="$(WEKA_38_URL)" \
	  --build-arg WEKA_PREFIX_ARG="$(WEKA_38_PREFIX_ARG)" \
	  --file $< \
	  -t "$(call make_image_name,$@)" \
	  .
	@mkdir -p "$(dir $@)"
	@touch $@


docker/weka36: weka.Dockerfile docker/base
	docker build \
	  --build-arg IMAGE="$(BASE_IMAGE)" \
	  --build-arg WEKA_VERSION="$(WEKA_36_VERSION)" \
	  --build-arg WEKA_URL="$(WEKA_36_URL)" \
	  --build-arg WEKA_PREFIX_ARG="$(WEKA_36_PREFIX_ARG)" \
	  --file $< \
	  -t "$(call make_image_name,$@)" \
	  .
	@mkdir -p "$(dir $@)"
	@touch $@


docker/emboss: emboss.Dockerfile docker/base
	docker build \
	  --build-arg IMAGE="$(BASE_IMAGE)" \
	  --build-arg EMBOSS_VERSION="$(EMBOSS_VERSION)" \
	  --build-arg EMBOSS_URL="$(EMBOSS_URL)" \
	  --build-arg EMBOSS_PREFIX_ARG="$(EMBOSS_PREFIX_ARG)" \
	  --file $< \
	  -t "$(call make_image_name,$@)" \
	  .
	@mkdir -p "$(dir $@)"
	@touch $@


docker/effectorp1: effectorp1.Dockerfile docker/base docker/weka36 docker/emboss docker/ffindex
	docker build \
	  --build-arg IMAGE="$(BASE_IMAGE)" \
	  --build-arg EFFECTORP1_VERSION="$(EFFECTORP1_VERSION)" \
	  --build-arg EFFECTORP1_URL="$(EFFECTORP1_URL)" \
	  --build-arg EFFECTORP1_PREFIX_ARG="$(EFFECTORP1_PREFIX_ARG)" \
	  --build-arg EMBOSS_IMAGE="$(call make_image_name,emboss)" \
	  --build-arg EMBOSS_VERSION="$(EMBOSS_VERSION)" \
	  --build-arg EMBOSS_PREFIX_ARG="$(EMBOSS_PREFIX_ARG)" \
	  --build-arg WEKA_36_IMAGE="$(call make_image_name,weka36)" \
	  --build-arg WEKA_36_VERSION="$(WEKA_36_VERSION)" \
	  --build-arg WEKA_36_PREFIX_ARG="$(WEKA_36_PREFIX_ARG)" \
	  --build-arg FFINDEX_IMAGE="$(call make_image_name,ffindex)" \
	  --build-arg FFINDEX_TAG="$(FFINDEX_TAG)" \
	  --build-arg FFINDEX_PREFIX_ARG="$(FFINDEX_PREFIX_ARG)" \
	  --file $< \
	  -t "$(call make_image_name,$@)" \
	  .
	@mkdir -p "$(dir $@)"
	@touch $@


docker/effectorp2: effectorp2.Dockerfile docker/base docker/weka38 docker/emboss docker/ffindex
	docker build \
	  --build-arg IMAGE="$(BASE_IMAGE)" \
	  --build-arg EFFECTORP2_VERSION="$(EFFECTORP2_VERSION)" \
	  --build-arg EFFECTORP2_URL="$(EFFECTORP2_URL)" \
	  --build-arg EFFECTORP2_PREFIX_ARG="$(EFFECTORP2_PREFIX_ARG)" \
	  --build-arg EMBOSS_IMAGE="$(call make_image_name,emboss)" \
	  --build-arg EMBOSS_VERSION="$(EMBOSS_VERSION)" \
	  --build-arg EMBOSS_PREFIX_ARG="$(EMBOSS_PREFIX_ARG)" \
	  --build-arg WEKA_38_IMAGE="$(call make_image_name,weka38)" \
	  --build-arg WEKA_38_VERSION="$(WEKA_38_VERSION)" \
	  --build-arg WEKA_38_PREFIX_ARG="$(WEKA_38_PREFIX_ARG)" \
	  --build-arg FFINDEX_IMAGE="$(call make_image_name,ffindex)" \
	  --build-arg FFINDEX_TAG="$(FFINDEX_TAG)" \
	  --build-arg FFINDEX_PREFIX_ARG="$(FFINDEX_PREFIX_ARG)" \
	  --file $< \
	  -t "$(call make_image_name,$@)" \
	  .
	@mkdir -p "$(dir $@)"
	@touch $@


docker/localizer: localizer.Dockerfile docker/base docker/weka36 docker/emboss docker/ffindex
	docker build \
	  --build-arg IMAGE="$(BASE_IMAGE)" \
	  --build-arg LOCALIZER_VERSION="$(LOCALIZER_VERSION)" \
	  --build-arg LOCALIZER_URL="$(LOCALIZER_URL)" \
	  --build-arg LOCALIZER_PREFIX_ARG="$(LOCALIZER_PREFIX_ARG)" \
	  --build-arg EMBOSS_IMAGE="$(call make_image_name,emboss)" \
	  --build-arg EMBOSS_VERSION="$(EMBOSS_VERSION)" \
	  --build-arg EMBOSS_PREFIX_ARG="$(EMBOSS_PREFIX_ARG)" \
	  --build-arg WEKA_36_IMAGE="$(call make_image_name,weka36)" \
	  --build-arg WEKA_36_VERSION="$(WEKA_36_VERSION)" \
	  --build-arg WEKA_36_PREFIX_ARG="$(WEKA_36_PREFIX_ARG)" \
	  --build-arg FFINDEX_IMAGE="$(call make_image_name,ffindex)" \
	  --build-arg FFINDEX_TAG="$(FFINDEX_TAG)" \
	  --build-arg FFINDEX_PREFIX_ARG="$(FFINDEX_PREFIX_ARG)" \
	  --file $< \
	  -t "$(call make_image_name,$@)" \
	  .
	@mkdir -p "$(dir $@)"
	@touch $@


docker/apoplastp: apoplastp.Dockerfile docker/base docker/weka38 docker/emboss docker/ffindex
	docker build \
	  --build-arg IMAGE="$(BASE_IMAGE)" \
	  --build-arg APOPLASTP_VERSION="$(APOPLASTP_VERSION)" \
	  --build-arg APOPLASTP_URL="$(APOPLASTP_URL)" \
	  --build-arg APOPLASTP_PREFIX_ARG="$(APOPLASTP_PREFIX_ARG)" \
	  --build-arg EMBOSS_IMAGE="$(call make_image_name,emboss)" \
	  --build-arg EMBOSS_VERSION="$(EMBOSS_VERSION)" \
	  --build-arg EMBOSS_PREFIX_ARG="$(EMBOSS_PREFIX_ARG)" \
	  --build-arg WEKA_38_IMAGE="$(call make_image_name,weka38)" \
	  --build-arg WEKA_38_VERSION="$(WEKA_38_VERSION)" \
	  --build-arg WEKA_38_PREFIX_ARG="$(WEKA_38_PREFIX_ARG)" \
	  --build-arg FFINDEX_IMAGE="$(call make_image_name,ffindex)" \
	  --build-arg FFINDEX_TAG="$(FFINDEX_TAG)" \
	  --build-arg FFINDEX_PREFIX_ARG="$(FFINDEX_PREFIX_ARG)" \
	  --file $< \
	  -t "$(call make_image_name,$@)" \
	  .
	@mkdir -p "$(dir $@)"
	@touch $@
