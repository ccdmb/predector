ARG IMAGE
ARG GFFPAL_IMAGE

FROM "${GFFPAL_IMAGE}" as gffpal_builder

FROM "${IMAGE}" as seqrenamer_builder

ARG SEQRENAMER_TAG
ARG SEQRENAMER_REPO="https://github.com/darcyabjones/seqrenamer.git"
ARG SEQRENAMER_PREFIX_ARG="/opt/seqrenamer/${SEQRENAMER_TAG}"
ENV SEQRENAMER_PREFIX="${SEQRENAMER_PREFIX_ARG}"

ARG GFFPAL_TAG
ARG GFFPAL_PREFIX_ARG="/opt/gffpal/${GFFPAL_TAG}"
ENV GFFPAL_PREFIX="${GFFPAL_PREFIX_ARG}"
LABEL gffpal.version="${GFFPAL_TAG}"

ENV PATH "${GFFPAL_PREFIX}/bin:${PATH}"

COPY --from=gffpal_builder "${GFFPAL_PREFIX}" "${GFFPAL_PREFIX}"
COPY --from=gffpal_builder "${PYTHON3_SITE_PTH_FILE}" "${PYTHON3_SITE_DIR}/gffpal.pth"
COPY --from=gffpal_builder "${APT_REQUIREMENTS_FILE}" /build/apt/gffpal.txt


WORKDIR /tmp
RUN  set -eu \
  && DEBIAN_FRONTEND=noninteractive \
  && . /build/base.sh \
  && apt-get update \
  && apt_install_from_file /build/apt/*.txt \
  && apt-get install -y --no-install-recommends \
       build-essential \
       ca-certificates \
       python3 \
       python3-pip \
       python3-setuptools \
       python3-wheel \
       git \
  && rm -rf /var/lib/apt/lists/* \
  && update-ca-certificates \
  && git clone "${SEQRENAMER_REPO}" . \
  && git fetch --tags \
  && git checkout "tags/${SEQRENAMER_TAG}" \
  && pip3 install --prefix="${SEQRENAMER_PREFIX}" . \
  && add_python3_site "${SEQRENAMER_PREFIX}/lib/python3.7/site-packages" \
  && add_runtime_dep python3


FROM "${IMAGE}"

ARG SEQRENAMER_TAG
ARG SEQRENAMER_PREFIX_ARG="/opt/seqrenamer/${SEQRENAMER_TAG}"
ENV SEQRENAMER_PREFIX="${SEQRENAMER_PREFIX_ARG}"
LABEL seqrenamer.version="${SEQRENAMER_TAG}"

ENV PATH "${SEQRENAMER_PREFIX}/bin:${PATH}"

COPY --from=seqrenamer_builder "${SEQRENAMER_PREFIX}" "${SEQRENAMER_PREFIX}"
COPY --from=seqrenamer_builder "${PYTHON3_SITE_PTH_FILE}" "${PYTHON3_SITE_DIR}/seqrenamer.pth"
COPY --from=seqrenamer_builder "${APT_REQUIREMENTS_FILE}" /build/apt/seqrenamer.txt


ARG GFFPAL_TAG
ARG GFFPAL_PREFIX_ARG="/opt/gffpal/${GFFPAL_TAG}"
ENV GFFPAL_PREFIX="${GFFPAL_PREFIX_ARG}"
LABEL gffpal.version="${GFFPAL_TAG}"

ENV PATH "${GFFPAL_PREFIX}/bin:${PATH}"

COPY --from=gffpal_builder "${GFFPAL_PREFIX}" "${GFFPAL_PREFIX}"
COPY --from=gffpal_builder "${PYTHON3_SITE_PTH_FILE}" "${PYTHON3_SITE_DIR}/gffpal.pth"
COPY --from=gffpal_builder "${APT_REQUIREMENTS_FILE}" /build/apt/gffpal.txt


RUN  set -eu \
  && DEBIAN_FRONTEND=noninteractive \
  && . /build/base.sh \
  && apt-get update \
  && apt_install_from_file /build/apt/*.txt \
  && rm -rf /var/lib/apt/lists/* \
  && cat "${PYTHON3_SITE_DIR}/gffpal.pth" >> "${PYTHON3_SITE_PTH_FILE}" \
  && cat "${PYTHON3_SITE_DIR}/seqrenamer.pth" >> "${PYTHON3_SITE_PTH_FILE}" \
  && cat /build/apt/*.txt >> "${APT_REQUIREMENTS_FILE}"

WORKDIR /
