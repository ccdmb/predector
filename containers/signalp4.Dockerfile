ARG IMAGE
ARG FFINDEX_IMAGE

FROM "${FFINDEX_IMAGE}" as ffindex_builder

FROM "${IMAGE}"

ARG SIGNALP4_VERSION
ARG SIGNALP4_PREFIX_ARG
ARG SIGNALP4_TAR
ENV SIGNALP4_PREFIX="${SIGNALP4_PREFIX_ARG}"
LABEL signalp4.version="${SIGNALP4_VERSION}"

ENV PATH="${SIGNALP4_PREFIX}:${PATH}"

COPY "${SIGNALP4_TAR}" /tmp/signalp.tar.gz


ARG FFINDEX_TAG
ARG FFINDEX_PREFIX_ARG
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
  && add_runtime_dep perl \
  && apt-get update \
  && apt_install_from_file "${APT_REQUIREMENTS_FILE}" \
  && apt_install_from_file /build/apt/*.txt \
  && rm -rf /var/lib/apt/lists/* \
  && tar xf signalp.tar.gz \
  && rm signalp.tar.gz \
  && mkdir -p "${SIGNALP4_PREFIX%/*}" \
  && mv signalp* "${SIGNALP4_PREFIX}" \
  && sed -i "s~/usr/cbs/bio/src/signalp-4.1~${SIGNALP4_PREFIX}~" "${SIGNALP4_PREFIX}/signalp" \
  && sed -i "s~/var/tmp~/tmp~" "${SIGNALP4_PREFIX}/signalp" \
  && sed -i "s~MAX_ALLOWED_ENTRIES=10000~MAX_ALLOWED_ENTRIES=999999999999999~" "${SIGNALP4_PREFIX}/signalp" \
  && ln -sf "${SIGNALP4_PREFIX}/signalp" "${SIGNALP4_PREFIX}/signalp-${SIGNALP4_VERSION}" \
  && cat /build/apt/*.txt >> "${APT_REQUIREMENTS_FILE}"

WORKDIR /
