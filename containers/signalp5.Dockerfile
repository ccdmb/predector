ARG IMAGE
ARG FFINDEX_IMAGE

FROM "${FFINDEX_IMAGE}" as ffindex_builder

FROM "${IMAGE}"

ARG SIGNALP5_VERSION
ARG SIGNALP5_PREFIX_ARG
ARG SIGNALP5_TAR
ENV SIGNALP5_PREFIX="${SIGNALP5_PREFIX_ARG}"
ENV PATH="${SIGNALP5_PREFIX}/bin:${PATH}"
LABEL signalp5.version="${SIGNALP5_VERSION}"


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


# Signalp needs to be called as the full path to the executable.
# So the shell script just wraps it so we can call it on the PATH
COPY "${SIGNALP5_TAR}" /tmp/signalp.tar.gz
WORKDIR /tmp
RUN  set -eu \
  && . /build/base.sh \
  && apt-get update \
  && apt_install_from_file /build/apt/*.txt \
  && rm -rf /var/lib/apt/lists/* \
  && tar -zxf signalp.tar.gz \
  && rm signalp.tar.gz \
  && mkdir "${SIGNALP5_PREFIX%/*}" \
  && mv signalp* "${SIGNALP5_PREFIX}" \
  && cd "${SIGNALP5_PREFIX}" \
  && mv "${SIGNALP5_PREFIX}/bin" "${SIGNALP5_PREFIX}/exe" \
  && mkdir -p "${SIGNALP5_PREFIX}/bin" \
  && echo "#!/usr/bin/env sh" > "${SIGNALP5_PREFIX}/bin/signalp" \
  && echo '${SIGNALP5_PREFIX}/exe/signalp $*' >> "${SIGNALP5_PREFIX}/bin/signalp" \
  && chmod a+x "${SIGNALP5_PREFIX}/bin/signalp" \
  && ln -sf "${SIGNALP5_PREFIX}/bin/signalp" "${SIGNALP5_PREFIX}/bin/signalp-${SIGNALP5_VERSION}" \
  && rm -rf -- "${SIGNALP5_PREFIX}/signalp.1" "${SIGNALP5_PREFIX}/test" \
  && cat /build/apt/*.txt >> "${APT_REQUIREMENTS_FILE}"

WORKDIR /
