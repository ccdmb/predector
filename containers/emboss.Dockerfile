ARG IMAGE

FROM "${IMAGE}" as emboss_builder

ARG EMBOSS_VERSION="6.5.7"
ARG EMBOSS_URL="ftp://emboss.open-bio.org/pub/EMBOSS/old/6.5.0/EMBOSS-6.5.7.tar.gz"
ARG EMBOSS_PREFIX_ARG="/opt/emboss/${EMBOSS_VERSION}"
ENV EMBOSS_PREFIX="${EMBOSS_PREFIX_ARG}"

WORKDIR /tmp
RUN  set -eu \
  && DEBIAN_FRONTEND=noninteractive \
  && . /build/base.sh \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
       build-essential \
       wget \
  && rm -rf /var/lib/apt/lists/* \
  && wget -O emboss.tar.gz "${EMBOSS_URL}" \
  && tar xf emboss.tar.gz \
  && cd EMBOSS-${EMBOSS_VERSION} \
  && ./configure --without-x --prefix "${EMBOSS_PREFIX}" \
  && make \
  && make install \
  && rm -rf -- "${EMBOSS_PREFIX}/share/EMBOSS/doc" "${EMBOSS_PREFIX}/share/EMBOSS/test"


FROM "${IMAGE}"

ARG EMBOSS_VERSION="6.5.7"
ARG EMBOSS_PREFIX_ARG="/opt/emboss/${EMBOSS_VERSION}"
ENV EMBOSS_PREFIX="${EMBOSS_PREFIX_ARG}"
LABEL emboss.version="${EMBOSS_VERSION}"

ENV PATH="${EMBOSS_PREFIX}/bin:${PATH}"
ENV CPATH="${EMBOSS_PREFIX}/include:${CPATH}"
ENV LIBRARY_PATH="${EMBOSS_PREFIX}/lib:${LIBRARY_PATH}"
ENV LD_LIBRARY_PATH="${EMBOSS_PREFIX}/lib:${LD_LIBRARY_PATH}"

COPY --from=emboss_builder "${EMBOSS_PREFIX}" "${EMBOSS_PREFIX}"
COPY --from=emboss_builder "${APT_REQUIREMENTS_FILE}" /build/apt/emboss.txt

RUN  set -eu \
  && DEBIAN_FRONTEND=noninteractive \
  && . /build/base.sh \
  && apt-get update \
  && apt_install_from_file /build/apt/*.txt \
  && rm -rf /var/lib/apt/lists/* \
  && cat /build/apt/*.txt >> "${APT_REQUIREMENTS_FILE}"
