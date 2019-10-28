ARG IMAGE
ARG FFDB_IMAGE

FROM "${FFDB_IMAGE}" as ffdb_builder

FROM "${IMAGE}" as ffindex_builder

ARG FFINDEX_TAG="0.9.9.9"
ARG FFINDEX_REPO="https://github.com/ahcm/ffindex.git"
ARG FFINDEX_PREFIX_ARG="/opt/ffindex/${FFINDEX_VERSION}"
ENV FFINDEX_PREFIX="${FFINDEX_PREFIX_ARG}"

WORKDIR /tmp
RUN  set -eu \
  && DEBIAN_FRONTEND=noninteractive \
  && . /build/base.sh \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
       build-essential \
       ca-certificates \
       git \
       libbz2-dev \
       libmpich-dev \
       zlib1g-dev \
  && rm -rf -- /var/lib/apt/lists/* \
  && update-ca-certificates \
  && git clone "${FFINDEX_REPO}" . \
  && git fetch --tags \
  && git checkout "tags/${FFINDEX_TAG}" \
  && make HAVE_MPI=1 \
  && make test \
  && make install INSTALL_DIR="${FFINDEX_PREFIX}" \
  && install src/ffindex_apply_mpi "${FFINDEX_PREFIX}/bin/ffindex_apply_mpi" \
  && add_runtime_dep libbz2-1.0 mpich zlib1g


FROM "${IMAGE}"

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


ARG FFDB_TAG
ARG FFDB_PREFIX_ARG="/opt/ffdb/${FFDB_TAG}"
ENV FFDB_PREFIX="${FFDB_PREFIX_ARG}"
LABEL ffdb.version="${FFDB_TAG}"

ENV PATH "${FFDB_PREFIX}/bin:${PATH}"
ENV PYTHONPATH "${FFDB_PREFIX}/lib/python3.7/site-packages:${PYTHONPATH}"

COPY --from=ffdb_builder "${FFDB_PREFIX}" "${FFDB_PREFIX}"
COPY --from=ffdb_builder "${APT_REQUIREMENTS_FILE}" /build/apt/ffdb.txt


RUN  set -eu \
  && DEBIAN_FRONTEND=noninteractive \
  && . /build/base.sh \
  && apt-get update \
  && apt_install_from_file /build/apt/*.txt \
  && rm -rf /var/lib/apt/lists/* \
  && cat /build/apt/*.txt >> "${APT_REQUIREMENTS_FILE}"
