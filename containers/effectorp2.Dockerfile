ARG IMAGE="darcyabjones/base"
ARG WEKA_38_IMAGE
ARG EMBOSS_IMAGE
ARG FFINDEX_IMAGE

FROM "${WEKA_38_IMAGE}" as weka_builder
FROM "${EMBOSS_IMAGE}" as emboss_builder
FROM "${FFINDEX_IMAGE}" as ffindex_builder

FROM "${IMAGE}" as effectorp2_builder

ARG EFFECTORP2_VERSION="2.0"
ARG EFFECTORP2_URL="http://effectorp.csiro.au/EffectorP_2.0.tar.gz"
ARG EFFECTORP2_PREFIX_ARG="/opt/effectorp/${EFFECTORP2_VERSION}"
ENV EFFECTORP2_PREFIX="${EFFECTORP2_PREFIX_ARG}"
ENV PATH="${EFFECTORP2_PREFIX}/Scripts:${PATH}"

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
  && wget -O effectorp2.tar.gz "${EFFECTORP2_URL}" \
  && tar xf effectorp2.tar.gz \
  && rm effectorp2.tar.gz \
  && mkdir -p "${EFFECTORP2_PREFIX%/*}" \
  && mv EffectorP* "${EFFECTORP2_PREFIX}" \
  && rm ${EFFECTORP2_PREFIX}/Scripts/*.tar.gz \
  && rm ${EFFECTORP2_PREFIX}/Scripts/*.zip \
  && ln -sf "${WEKA_38_PREFIX}" "${EFFECTORP2_PREFIX}/Scripts/weka-3-8-1" \
  && chmod a+x "${EFFECTORP2_PREFIX}/Scripts/EffectorP.py" \
  && sed -i "s~/usr/bin/python~/usr/bin/env python~" "${EFFECTORP2_PREFIX}/Scripts/EffectorP.py" \
  && sed -i "s~SCRIPT_PATH + '/EMBOSS-6.5.7/emboss/'~'${EMBOSS_PREFIX}/bin/'~" "${EFFECTORP2_PREFIX}/Scripts/EffectorP.py" \
  && ln -sf "${EFFECTORP2_PREFIX}/Scripts/EffectorP.py" "${EFFECTORP2_PREFIX}/Scripts/EffectorP-${EFFECTORP2_VERSION}.py" \
  && add_runtime_dep python python-biopython


FROM "${IMAGE}"

ARG EFFECTORP2_VERSION="2.0"
ARG EFFECTORP2_PREFIX_ARG="/opt/effectorp/${EFFECTORP2_VERSION}"
ENV EFFECTORP2_PREFIX="${EFFECTORP2_PREFIX_ARG}"
LABEL effectorp2.version="${EFFECTORP2_VERSION}"

ENV PATH="${EFFECTORP2_PREFIX}/Scripts:${PATH}"

COPY --from=effectorp2_builder "${EFFECTORP2_PREFIX}" "${EFFECTORP2_PREFIX}"
COPY --from=effectorp2_builder "${APT_REQUIREMENTS_FILE}" /build/apt/effectorp2.txt


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
