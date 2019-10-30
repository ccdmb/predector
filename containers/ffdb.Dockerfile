ARG IMAGE

FROM "${IMAGE}" as ffdb_builder

ARG FFDB_TAG
ARG FFDB_REPO
ARG FFDB_PREFIX_ARG
ENV FFDB_PREFIX="${FFDB_PREFIX_ARG}"


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
       git \
  && rm -rf /var/lib/apt/lists/* \
  && update-ca-certificates \
  && git clone "${FFDB_REPO}" . \
  && git fetch --tags \
  && git checkout "${FFDB_TAG}" \
  && pip3 install --prefix="${FFDB_PREFIX}" . \
  && add_python3_site "${FFDB_PREFIX}/lib/python3.7/site-packages" \
  && add_runtime_dep python3


FROM "${IMAGE}"

ARG FFDB_TAG
ARG FFDB_PREFIX_ARG
ENV FFDB_PREFIX="${FFDB_PREFIX_ARG}"
LABEL ffdb.version="${FFDB_TAG}"

ENV PATH "${FFDB_PREFIX}/bin:${PATH}"

COPY --from=ffdb_builder "${FFDB_PREFIX}" "${FFDB_PREFIX}"
COPY --from=ffdb_builder "${PYTHON3_SITE_PTH_FILE}" "${PYTHON3_SITE_DIR}/ffdb.pth"
COPY --from=ffdb_builder "${APT_REQUIREMENTS_FILE}" /build/apt/ffdb.txt

RUN  set -eu \
  && DEBIAN_FRONTEND=noninteractive \
  && . /build/base.sh \
  && apt-get update \
  && apt_install_from_file /build/apt/*.txt \
  && rm -rf /var/lib/apt/lists/* \
  && cat /build/apt/*.txt >> "${APT_REQUIREMENTS_FILE}"

WORKDIR /
