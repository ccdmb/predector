FROM mambaorg/micromamba:1.4-jammy

ENV ENVIRONMENT=predector
ENV VERSION=1.2.7

LABEL maintainer="darcy.ab.jones@gmail.com"
LABEL description="Docker image containing all non-proprietary requirements for the predector pipeline"
LABEL pipeline.name="${ENVIRONMENT}"
LABEL pipeline.version="${VERSION}"

USER root

RUN apt-get update \
 && apt-get install -y procps libtinfo6 \
 && apt-get clean -y \
 && chmod -R ugo+rws /opt

USER $MAMBA_USER

COPY --chown=$MAMBA_USER:$MAMBA_USER environment.yml /tmp/environment.yml

RUN \
    micromamba install --yes -n base -c predector -c conda-forge -c bioconda --file /tmp/environment.yml \
 && micromamba clean --all --yes

ENV MAMBA_DOCKERFILE_ACTIVATE=1


## Needed for theano/deeploc
#ENV CC="${CONDA_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-cc"
#ENV CXX="${CONDA_PREFIX}/bin/x86_64-conda_cos6-linux-gnu-c++"
