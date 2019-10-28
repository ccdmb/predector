ARG DEBIAN_VERSION

FROM debian:${DEBIAN_VERSION}

ARG MAINTAINER
ARG PIPELINE_VERSION
LABEL maintainer="${MAINTAINER}"
LABEL version="${PIPELINE_VERSION}"

# Set these with empty defaults to avoid using unset variables in path adds
ENV PATH "${PATH:-}"
ENV INCLUDE "${INCLUDE:-}"
ENV CPATH "${CPATH:-}"
ENV LIBRARY_PATH "${LIBRARY_PATH:-}"
ENV LD_LIBRARY_PATH "${LD_LIBRARY_PATH:-}"
ENV LD_RUN_PATH "${LD_RUN_PATH:-}"

ENV LANG "C.UTF-8"
ENV LANGUAGE "C.UTF-8"
ENV LC_ALL "C.UTF-8"

ENV BUILD_DIR "/build"
ENV APT_REQUIREMENTS_FILE "${BUILD_DIR}/apt-requirements.txt"

COPY base.sh /build/base.sh

RUN  set -eu \
  && DEBIAN_FRONTEND=noninteractive \
  && mkdir -p /usr/share/man/man1 \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
       bash \
       curl \
       gawk \
       sed \
       procps \
       wget \
  && rm -rf /var/lib/apt/lists/* \
  && touch "${APT_REQUIREMENTS_FILE}"

# Adding man folder prevents java install from panicking
