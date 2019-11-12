ARG IMAGE
ARG SIGNALP3_IMAGE
ARG FFINDEX_IMAGE

FROM "${SIGNALP3_IMAGE}" as signalp3_builder
FROM "${FFINDEX_IMAGE}" as ffindex_builder

FROM "${IMAGE}"
LABEL maintainer="darcy.ab.jones@gmail.com"

ARG SIGNALP3_VERSION
ARG SIGNALP3_PREFIX_ARG
ENV SIGNALP3_PREFIX="${SIGNALP3_PREFIX_ARG}"
LABEL signalp3.version="${SIGNALP3_VERSION}"

ENV PATH="${SIGNALP3_PREFIX}:${PATH}"

COPY --from=signalp3_builder "${SIGNALP3_PREFIX}" "${SIGNALP3_PREFIX}"
COPY --from=signalp3_builder "${APT_REQUIREMENTS_FILE}" /build/apt/signalp3.txt


ARG CHLOROP_VERSION
ARG CHLOROP_PREFIX_ARG
ARG CHLOROP_TAR
ENV CHLOROP_PREFIX="${CHLOROP_PREFIX_ARG}"
LABEL chlorop.version="${CHLOROP_VERSION}"

ENV PATH="${CHLOROP_PREFIX}:${PATH}"

COPY "${CHLOROP_TAR}" /tmp/chlorop.tar.Z


ARG TARGETP_VERSION
ARG TARGETP_PREFIX_ARG
ARG TARGETP_TAR
ENV TARGETP_PREFIX="${TARGETP_PREFIX_ARG}"
LABEL targetp.version="${TARGETP_VERSION}"

ENV PATH="${TARGETP_PREFIX}:${PATH}"

COPY "${TARGETP_TAR}" /tmp/targetp.tar.Z


ARG FFINDEX_TAG
ARG FFINDEX_PREFIX_ARG
ENV FFINDEX_PREFIX
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
  && add_runtime_dep gawk perl \
  && apt-get update \
  && apt_install_from_file /build/apt/*.txt \
  && apt_install_from_file "${APT_REQUIREMENTS_FILE}" \
  && rm -rf /var/lib/apt/lists/* \
  && tar xf chlorop.tar.Z \
  && rm chlorop.tar.Z \
  && mkdir -p "${CHLOROP_PREFIX%/*}" \
  && mv chlorop* "${CHLOROP_PREFIX}" \
  && sed -i "s~/usr/cbs/packages/chlorop/currdist/chlorop-1.1~${CHLOROP_PREFIX}~" "${CHLOROP_PREFIX}/chlorop" \
  && sed -i "s~AWK=nawk~AWK=gawk~" "${CHLOROP_PREFIX}/chlorop" \
  && sed -i 's~CHLOROTMP=tmp~CHLOROTMP=$STARTDIR~' "${CHLOROP_PREFIX}/chlorop" \
  && sed -i 's~$CHLOROP/$CHLOROTMP~$CHLOROTMP~' "${CHLOROP_PREFIX}/chlorop" \
  && sed -i "s~mkdir~mkdir -p~" "${CHLOROP_PREFIX}/chlorop" \
  && ln -sf "${CHLOROP_PREFIX}/chlorop" "${CHLOROP_PREFIX}/chlorop-${CHLOROP_VERSION}" \
  && tar xf targetp.tar.Z \
  && rm targetp.tar.Z \
  && mkdir -p "${TARGETP_PREFIX%/*}" \
  && mv targetp* "${TARGETP_PREFIX}" \
  && sed -i "s~/usr/cbs/packages/targetp/currdist/targetp-1.1~${TARGETP_PREFIX}~" "${TARGETP_PREFIX}/targetp" \
  && mkdir -p /tmp \
  && sed -i "s~/scratch~/tmp~" "${TARGETP_PREFIX}/targetp" \
  && sed -i "s~/usr/bin/perl~$(which perl)~" "${TARGETP_PREFIX}/targetp" \
  && sed -i "s~AWK=/usr/freeware/bin/gawk~AWK=\"$(which gawk)\"~" "${TARGETP_PREFIX}/targetp" \
  && sed -i "s~/usr/cbs/bio/bin/chlorop~${CHLOROP_PREFIX}/chlorop~" "${TARGETP_PREFIX}/targetp" \
  && sed -i "s~/usr/cbs/bio/bin/signalp~${SIGNALP3_PREFIX}/signalp~" "${TARGETP_PREFIX}/targetp" \
  && ln -sf "${TARGETP_PREFIX}/targetp" "${TARGETP_PREFIX}/targetp-${TARGETP_VERSION}" \
  && cat /build/apt/*.txt >> "${APT_REQUIREMENTS_FILE}"

WORKDIR /
