ARG IMAGE
ARG HMMER3_IMAGE
ARG FFINDEX_IMAGE

FROM "${HMMER3_IMAGE}" as hmmer3_builder
FROM "${FFINDEX_IMAGE}" as ffindex_builder

FROM "${IMAGE}" as pfamscan_builder

ARG PFAMSCAN_VERSION
ARG PFAMSCAN_URL
ARG PFAMSCAN_PREFIX_ARG
ENV PFAMSCAN_PREFIX="${PFAMSCAN_PREFIX_ARG}"

WORKDIR /tmp
RUN  set -eu \
  && DEBIAN_FRONTEND=noninteractive \
  && . /build/base.sh \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
       build-essential \
       wget \
  && rm -rf /var/lib/apt/lists/* \
  && wget -O pfamscan.tar.gz "${PFAMSCAN_URL}" \
  && tar -zxf pfamscan.tar.gz \
  && cd PfamScan \ 
  && mkdir -p "${PFAMSCAN_PREFIX}/bin" \
  && mv pfam_scan.pl Bio "${PFAMSCAN_PREFIX}/bin" \
  && add_runtime_dep perl bioperl libmoose-perl


FROM "${IMAGE}"

ARG PFAMSCAN_VERSION
ARG PFAMSCAN_URL
ARG PFAMSCAN_PREFIX_ARG
ENV PFAMSCAN_PREFIX="${PFAMSCAN_PREFIX_ARG}"

LABEL pfamscan.version="${PFAMSCAN_VERSION}"

ENV PATH="${PFAMSCAN_PREFIX}/bin:${PATH}"

COPY --from=pfamscan_builder "${PFAMSCAN_PREFIX}" "${PFAMSCAN_PREFIX}"
COPY --from=pfamscan_builder "${APT_REQUIREMENTS_FILE}" /build/apt/pfamscan.txt

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

WORKDIR /
