ARG IMAGE

FROM "${IMAGE}" as gffpal_builder

ARG GFFPAL_TAG
ARG GFFPAL_REPO="https://github.com/darcyabjones/gffpal.git"
ARG GFFPAL_PREFIX_ARG="/opt/gffpal/${GFFPAL_TAG}"
ENV GFFPAL_PREFIX="${GFFPAL_PREFIX_ARG}"


WORKDIR /tmp
RUN  set -eu \
  && DEBIAN_FRONTEND=noninteractive \
  && . /build/base.sh \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
       build-essential \
       ca-certificates \
       python3 \
       python3-pip \
       python3-setuptools \
       python3-wheel \
       python3-biopython \
       git \
  && rm -rf /var/lib/apt/lists/* \
  && update-ca-certificates \
  && git clone "${GFFPAL_REPO}" . \
  && git fetch --tags \
  && git checkout "tags/${GFFPAL_TAG}" \
  && pip3 install --prefix="${GFFPAL_PREFIX}" . \
  && add_python3_site "${GFFPAL_PREFIX}/lib/python3.7/site-packages" \
  && add_runtime_dep python3 python3-biopython


FROM "${IMAGE}"

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
  && cat /build/apt/*.txt >> "${APT_REQUIREMENTS_FILE}"

WORKDIR /
