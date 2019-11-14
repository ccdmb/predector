ARG IMAGE
ARG FFINDEX_IMAGE

FROM "${FFINDEX_IMAGE}" as ffindex_builder
FROM "${IMAGE}" as hmmer3_builder

ARG HMMER3_VERSION
ARG HMMER3_URL
ARG HMMER3_PREFIX_ARG
ENV HMMER3_PREFIX="${HMMER3_PREFIX_ARG}"


WORKDIR /tmp
RUN  set -eu \
  && DEBIAN_FRONTEND=noninteractive \
  && . /build/base.sh \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
       build-essential \
       wget \
  && rm -rf /var/lib/apt/lists/* \
  && wget -O hmmer.tar.gz "${HMMER3_URL}" \
  && tar xf hmmer.tar.gz \
  && rm hmmer.tar.gz \
  && cd hmmer-*/ \
  && ./configure --prefix="${HMMER3_PREFIX}" \
  && make \
  && make check \
  && make install \
  && cd easel \
  && make install


FROM "${IMAGE}"

ARG HMMER3_VERSION
ARG HMMER3_PREFIX_ARG
ENV HMMER3_PREFIX="${HMMER3_PREFIX_ARG}"

ENV PATH="${HMMER3_PREFIX}/bin:${PATH}"

LABEL hmmer3.version="${HMMER3_VERSION}"

COPY --from=hmmer3_builder "${HMMER3_PREFIX}" "${HMMER3_PREFIX}"
COPY --from=hmmer3_builder "${APT_REQUIREMENTS_FILE}" /build/apt/hmmer3.txt


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

RUN  set -eu \
  && DEBIAN_FRONTEND=noninteractive \
  && . /build/base.sh \
  && apt-get update \
  && apt_install_from_file /build/apt/*.txt \
  && rm -rf /var/lib/apt/lists/* \
  && cat /build/apt/*.txt >> "${APT_REQUIREMENTS_FILE}"
