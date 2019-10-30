ARG IMAGE

FROM "${IMAGE}" as weka_builder

# https://sourceforge.net/projects/weka/files/weka-3-6/3.6.12/weka-3-6-12.zip/download
# https://sourceforge.net/projects/weka/files/weka-3-8/3.8.1/weka-3-8-1.zip/download

ARG WEKA_VERSION
ARG WEKA_URL
ARG WEKA_PREFIX_ARG
ENV WEKA_PREFIX="${WEKA_PREFIX_ARG}"
ENV WEKA_JAR="${WEKA_PREFIX}/weka.jar"

WORKDIR /tmp
RUN  set -eu \
  && DEBIAN_FRONTEND=noninteractive \
  && . /build/base.sh \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
       ca-certificates \
       unzip \
       wget \
  && rm -rf /var/lib/apt/lists/* \
  && update-ca-certificates \
  && wget -O weka.zip "${WEKA_URL}" \
  && unzip weka.zip \
  && rm *.zip \
  && mkdir -p "${WEKA_PREFIX%/*}" \
  && mv weka* "${WEKA_PREFIX}" \
  && rm -rf -- \
       "${WEKA_PREFIX}/doc" \
       "${WEKA_PREFIX}/WekaManual.pdf" \
       "${WEKA_PREFIX}/data" \
       "${WEKA_PREFIX}/wekaexamples.zip" \
       "${WEKA_PREFIX}/documentation.html" \
       "${WEKA_PREFIX}/documentation.css" \
       "${WEKA_PREFIX}/changelogs" \
       "${WEKA_PREFIX}/weka.gif" \
       "${WEKA_PREFIX}/weka.ico" \
  && add_runtime_dep default-jre-headless


FROM "${IMAGE}"

ARG WEKA_VERSION
ARG WEKA_PREFIX_ARG
ENV WEKA_PREFIX="${WEKA_PREFIX_ARG}"
ENV WEKA_JAR="${WEKA_PREFIX}/weka.jar"
LABEL weka.version="${WEKA_VERSION}"

ENV PATH="${WEKA_PREFIX}:${PATH}"

COPY --from=weka_builder "${WEKA_PREFIX}" "${WEKA_PREFIX}"
COPY --from=weka_builder "${APT_REQUIREMENTS_FILE}" /build/apt/weka.txt

RUN  set -eu \
  && DEBIAN_FRONTEND=noninteractive \
  && . /build/base.sh \
  && apt-get update \
  && apt_install_from_file /build/apt/*.txt \
  && rm -rf /var/lib/apt/lists/* \
  && cat /build/apt/*.txt >> "${APT_REQUIREMENTS_FILE}"
