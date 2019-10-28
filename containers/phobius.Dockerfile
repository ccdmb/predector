ARG IMAGE="darcyabjones/base"
ARG FFINDEX_IMAGE

FROM "${FFINDEX_IMAGE}" as ffindex_builder

FROM "${IMAGE}"

ARG PHOBIUS_VERSION
ARG PHOBIUS_PREFIX_ARG="/opt/phobius/${PHOBIUS_VERSION}"
ARG PHOBIUS_TAR="sources/phobius101_linux.tar.gz"
ENV PHOBIUS_PREFIX="${PHOBIUS_PREFIX_ARG}"
LABEL phobius.version="${PHOBIUS_VERSION}"

ENV PATH="${PHOBIUS_PREFIX}:${PATH}"

COPY "${PHOBIUS_TAR}" /tmp/phobius.tar.gz


ARG FFINDEX_TAG="0.9.9.9"
ARG FFINDEX_PREFIX_ARG="/opt/ffindex/${FFINDEX_VERSION}"
ENV FFINDEX_PREFIX="${FFINDEX_PREFIX_ARG}"
LABEL ffindex.version="${FFINDEX_VERSION}"

ENV LIBRARY_PATH="${FFINDEX_PREFIX}/lib:${LD_LIBRARY_PATH}"
ENV LD_LIBRARY_PATH="${LIBRARY_PATH}:${LD_LIBRARY_PATH}"
ENV CPATH="${FFINDEX_PREFIX}/include:${CPATH}"
ENV PATH="${FFINDEX_PREFIX}/bin:${PATH}"

COPY --from=ffindex_builder "${FFINDEX_PREFIX}" "${FFINDEX_PREFIX}"
COPY --from=ffindex_builder "${APT_REQUIREMENTS_FILE}" /build/apt/ffindex.txt


WORKDIR /tmp
RUN  set -eu \
  && . /build/base.sh \
  && add_runtime_dep bash perl \
  && apt-get update \
  && apt_install_from_file "${APT_REQUIREMENTS_FILE}" \
  && apt_install_from_file /build/apt/*.txt \
  && rm -rf /var/lib/apt/lists/* \
  && tar xf phobius.tar.gz \
  && rm phobius.tar.gz \
  && mkdir -p "${PHOBIUS_PREFIX%/*}" \
  && mv tmp/tmp*/phobius "${PHOBIUS_PREFIX}" \
  && rm -rf -- tmp \
  && sed -i "s~PHOBIUS_DIR/decodeanhmm~PHOBIUS_DIR/decodeanhmm.64bit~g" "${PHOBIUS_PREFIX}/phobius.pl" \
  && sed -i '181s/predstr/predstr=""/' "${PHOBIUS_PREFIX}/phobius.pl" \
  && sed -i '244a \$predstr="";' "${PHOBIUS_PREFIX}/phobius.pl" \
  && ln -sf "${PHOBIUS_PREFIX}/phobius.pl" "${PHOBIUS_PREFIX}/phobius-${PHOBIUS_VERSION}.pl" \
  && ln -sf "${PHOBIUS_PREFIX}/phobius.pl" "${PHOBIUS_PREFIX}/phobius" \
  && ln -sf "${PHOBIUS_PREFIX}/phobius.pl" "${PHOBIUS_PREFIX}/phobius-${PHOBIUS_VERSION}"

WORKDIR /
