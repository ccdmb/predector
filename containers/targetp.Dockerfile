ARG IMAGE
ARG FFINDEX_IMAGE

FROM "${FFINDEX_IMAGE}" as ffindex_builder

FROM "${IMAGE}"
LABEL maintainer="darcy.ab.jones@gmail.com"


ARG TARGETP_VERSION
ARG TARGETP_PREFIX_ARG
ARG TARGETP_TAR
ENV TARGETP_PREFIX="${TARGETP_PREFIX_ARG}"
LABEL targetp.version="${TARGETP_VERSION}"

ENV PATH="${TARGETP_PREFIX}/bin:${PATH}"
ENV LIBRARY_PATH="${TARGETP_PREFIX}/lib:${LIBRARY_PATH}"
ENV LD_LIBRARY_PATH="${TARGETP_PREFIX}/lib:${LD_LIBRARY_PATH}"

COPY "${TARGETP_TAR}" /tmp/targetp.tar.gz

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
  && add_runtime_dep gawk perl \
  && apt-get update \
  && apt_install_from_file /build/apt/*.txt \
  && apt_install_from_file "${APT_REQUIREMENTS_FILE}" \
  && rm -rf /var/lib/apt/lists/* \
  && tar zxf targetp.tar.gz \
  && rm targetp.tar.gz \
  && mkdir -p "${TARGETP_PREFIX%/*}" \
  && mv targetp*/ "${TARGETP_PREFIX}" \
  && rm -rf -- "${TARGETP_PREFIX}/test" \
  && cat /build/apt/*.txt >> "${APT_REQUIREMENTS_FILE}"

WORKDIR /
