ARG IMAGE
ARG FFINDEX_IMAGE

FROM "${FFINDEX_IMAGE}" as ffindex_builder

FROM "${IMAGE}"

ARG SIGNALP3_VERSION
ARG SIGNALP3_PREFIX_ARG
ARG SIGNALP3_TAR
ENV SIGNALP3_PREFIX="${SIGNALP3_PREFIX_ARG}"
LABEL signalp3.version="${SIGNALP3_VERSION}"

ENV PATH="${SIGNALP3_PREFIX}:${PATH}"

COPY "${SIGNALP3_TAR}" /tmp/signalp.tar.Z


ARG FFINDEX_TAG
ARG FFINDEX_PREFIX_ARG
ENV FFINDEX_PREFIX="${FFINDEX_PREFIX_ARG}"
LABEL ffindex.version="${FFINDEX_VERSION}"

ENV LIBRARY_PATH="${FFINDEX_PREFIX}/lib:${LIBRARY_PATH}"
ENV LD_LIBRARY_PATH="${LIBRARY_PATH}:${LD_LIBRARY_PATH}"
ENV CPATH="${FFINDEX_PREFIX}/include:${CPATH}"
ENV PATH="${FFINDEX_PREFIX}/bin:${PATH}"

COPY --from=ffindex_builder "${FFINDEX_PREFIX}" "${FFINDEX_PREFIX}"
COPY --from=ffindex_builder "${APT_REQUIREMENTS_FILE}" /build/apt/ffindex.txt


WORKDIR /tmp
RUN  set -eu \
  && . /build/base.sh \
  && add_runtime_dep gawk \
  && apt-get update \
  && apt_install_from_file "${APT_REQUIREMENTS_FILE}" \
  && apt_install_from_file /build/apt/*.txt \
  && rm -rf /var/lib/apt/lists/* \
  && tar xf signalp.tar.Z \
  && rm signalp.tar.Z \
  && mkdir -p "${SIGNALP3_PREFIX%/*}" \
  && mv signalp* "${SIGNALP3_PREFIX}" \
  && cd "${SIGNALP3_PREFIX}" \
  && sed -i "s~SIGNALP=/usr/opt/signalp-3.0~SIGNALP=${SIGNALP3_PREFIX}~" "${SIGNALP3_PREFIX}/signalp" \
  && sed -i "s~AWK=nawk~AWK=gawk~" "${SIGNALP3_PREFIX}/signalp" \
  && sed -i "s~AWK=/usr/bin/gawk~AWK=gawk~" "${SIGNALP3_PREFIX}/signalp" \
  && sed -i 's~bin/testhow~bin/testhow -H $HOW~' "${SIGNALP3_PREFIX}/signalp" \
  && sed -i 's~TMPDIR=$SIGNALP/tmp/$TMPDIRNAME~TMPDIR=$DESTINATION/$TMPDIRNAME~' "${SIGNALP3_PREFIX}/signalp" \
  && sed -i 's~mkdir $TMPDIR~mkdir -p $TMPDIR~' "${SIGNALP3_PREFIX}/signalp" \
  && sed -i 's~`which nawk`~gawk~' "${SIGNALP3_PREFIX}/bin/testhow" \
  && ln -sf "${SIGNALP3_PREFIX}/signalp" "${SIGNALP3_PREFIX}/signalp-${SIGNALP3_VERSION}" \
  && cat /build/apt/*.txt >> "${APT_REQUIREMENTS_FILE}"

WORKDIR /
