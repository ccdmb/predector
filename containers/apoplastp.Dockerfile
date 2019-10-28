ARG IMAGE="darcyabjones/base"
ARG WEKA_38_IMAGE
ARG EMBOSS_IMAGE
ARG FFINDEX_IMAGE

FROM "${WEKA_38_IMAGE}" as weka_builder
FROM "${EMBOSS_IMAGE}" as emboss_builder
FROM "${FFINDEX_IMAGE}" as ffindex_builder

FROM "${IMAGE}" as apoplastp_builder

ARG APOPLASTP_VERSION="1.0.1"
ARG APOPLASTP_URL="http://apoplastp.csiro.au/ApoplastP_1.0.1.tar.gz"
ARG APOPLASTP_PREFIX_ARG="/opt/apoplastp/${APOPLASTP_VERSION}"
ENV APOPLASTP_PREFIX="${APOPLASTP_PREFIX_ARG}"

ARG WEKA_38_VERSION
ARG WEKA_38_PREFIX_ARG="/opt/weka/${WEKA_38_VERSION}"
ENV WEKA_38_PREFIX="${WEKA_38_PREFIX_ARG}"

ARG EMBOSS_VERSION="6.5.7"
ARG EMBOSS_PREFIX_ARG="/opt/emboss/${EMBOSS_VERSION}"
ENV EMBOSS_PREFIX="${EMBOSS_PREFIX_ARG}"

WORKDIR /tmp
RUN  set -eu \
  && DEBIAN_FRONTEND=noninteractive \
  && . /build/base.sh \
  && apt-get update \
  && apt-get install -y --no-install-recommends wget \
  && rm -rf /var/lib/apt/lists/* \
  && wget -O apoplastp.tar.gz "${APOPLASTP_URL}" \
  && tar xf apoplastp.tar.gz \
  && rm apoplastp.tar.gz \
  && mkdir -p "${APOPLASTP_PREFIX%/*}" \
  && mv ApoplastP* "${APOPLASTP_PREFIX}" \
  && rm ${APOPLASTP_PREFIX}/Scripts/*.tar.gz \
  && rm ${APOPLASTP_PREFIX}/Scripts/*.zip \
  && ln -sf "${WEKA_38_PREFIX}" "${APOPLASTP_PREFIX}/Scripts/weka-3-8-1" \
  && chmod a+x "${APOPLASTP_PREFIX}/Scripts/ApoplastP.py" \
  && sed -i "s~/usr/bin/python~/usr/bin/env python~" "${APOPLASTP_PREFIX}/Scripts/ApoplastP.py" \
  && sed -i "s~SCRIPT_PATH + '/EMBOSS-6.5.7/emboss/'~'${EMBOSS_PREFIX}/bin/'~" "${APOPLASTP_PREFIX}/Scripts/ApoplastP.py" \
  && ln -sf "${APOPLASTP_PREFIX}/Scripts/ApoplastP.py" "${APOPLASTP_PREFIX}/Scripts/ApoplastP-${APOPLASTP_VERSION}.py" \
  && add_runtime_dep python python-biopython


FROM "${IMAGE}"

ARG APOPLASTP_VERSION="1.0.1"
ARG APOPLASTP_PREFIX_ARG="/opt/apoplastp/${APOPLASTP_VERSION}"
ENV APOPLASTP_PREFIX="${APOPLASTP_PREFIX_ARG}"
LABEL apoplastp.version="${APOPLASTP_VERSION}"

ENV PATH="${APOPLASTP_PREFIX}/Scripts:${PATH}"

COPY --from=apoplastp_builder "${APOPLASTP_PREFIX}" "${APOPLASTP_PREFIX}"
COPY --from=apoplastp_builder "${APT_REQUIREMENTS_FILE}" /build/apt/apoplastp.txt


ARG WEKA_38_VERSION
ARG WEKA_38_PREFIX_ARG="/opt/weka/${WEKA_38_VERSION}"
ENV WEKA_38_PREFIX="${WEKA_38_PREFIX_ARG}"
ENV WEKA_38_JAR="${WEKA_38_PREFIX}/weka.jar"
LABEL weka.version="${WEKA_VERSION}"

ENV PATH="${WEKA_38_PREFIX}:${PATH}"

COPY --from=weka_builder "${WEKA_38_PREFIX}" "${WEKA_38_PREFIX}"
COPY --from=weka_builder "${APT_REQUIREMENTS_FILE}" /build/apt/weka38.txt


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


RUN  set -eu \
  && DEBIAN_FRONTEND=noninteractive \
  && . /build/base.sh \
  && apt-get update \
  && apt_install_from_file /build/apt/*.txt \
  && rm -rf /var/lib/apt/lists/* \
  && cat /build/apt/*.txt >> "${APT_REQUIREMENTS_FILE}"

WORKDIR /
