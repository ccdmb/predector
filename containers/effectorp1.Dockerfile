ARG IMAGE
ARG WEKA_36_IMAGE
ARG EMBOSS_IMAGE
ARG FFINDEX_IMAGE

FROM "${WEKA_36_IMAGE}" as weka_builder
FROM "${EMBOSS_IMAGE}" as emboss_builder
FROM "${FFINDEX_IMAGE}" as ffindex_builder

FROM "${IMAGE}" as effectorp1_builder

ARG EFFECTORP1_VERSION
ARG EFFECTORP1_URL
ARG EFFECTORP1_PREFIX_ARG
ENV EFFECTORP1_PREFIX="${EFFECTORP1_PREFIX_ARG}"
ENV PATH="${EFFECTORP1_PREFIX}:${PATH}"

ARG WEKA_36_VERSION
ARG WEKA_36_PREFIX_ARG
ENV WEKA_36_PREFIX="${WEKA_36_PREFIX_ARG}"

ARG EMBOSS_VERSION
ARG EMBOSS_PREFIX_ARG
ENV EMBOSS_PREFIX="${EMBOSS_PREFIX_ARG}"

WORKDIR /tmp
RUN  set -eu \
  && DEBIAN_FRONTEND=noninteractive \
  && . /build/base.sh \
  && apt-get update \
  && apt-get install -y --no-install-recommends wget \
  && rm -rf /var/lib/apt/lists/* \
  && wget -O effectorp1.tar.gz "${EFFECTORP1_URL}" \
  && tar xf effectorp1.tar.gz \
  && rm effectorp1.tar.gz \
  && mkdir -p "${EFFECTORP1_PREFIX%/*}" \
  && mv EffectorP* "${EFFECTORP1_PREFIX}" \
  && rm ${EFFECTORP1_PREFIX}/Scripts/*.tar.gz \
  && rm ${EFFECTORP1_PREFIX}/Scripts/*.zip \
  && rm ${EFFECTORP1_PREFIX}/*.pdf \
  && ln -sf "${WEKA_36_PREFIX}" "${EFFECTORP1_PREFIX}/Scripts/weka-3-6-12" \
  && chmod a+x "${EFFECTORP1_PREFIX}/Scripts/EffectorP.py" \
  && sed -i "s~/usr/bin/python~/usr/bin/env python~" "${EFFECTORP1_PREFIX}/Scripts/EffectorP.py" \
  && sed -i "s~SCRIPT_PATH + '/tmp/'~'tmp_'~" "${EFFECTORP1_PREFIX}/Scripts/EffectorP.py" \
  && sed -i "s~os.makedirs('tmp_')~os.makedirs('tmp_' + FOLDER_IDENTIFIER)~" "${EFFECTORP1_PREFIX}/Scripts/EffectorP.py" \
  && sed -i "s~SCRIPT_PATH + '/EMBOSS-6.5.7/emboss/'~'${EMBOSS_PREFIX}/bin/'~" "${EFFECTORP1_PREFIX}/Scripts/EffectorP.py" \
  && ln -sf "${EFFECTORP1_PREFIX}/Scripts/EffectorP.py" "${EFFECTORP1_PREFIX}/Scripts/EffectorP-${EFFECTORP1_VERSION}.py" \
  && add_runtime_dep python


FROM "${IMAGE}"

ARG EFFECTORP1_VERSION
ARG EFFECTORP1_PREFIX_ARG
ENV EFFECTORP1_PREFIX="${EFFECTORP1_PREFIX_ARG}"
LABEL effectorp1.version="${EFFECTORP1_VERSION}"

ENV PATH="${EFFECTORP1_PREFIX}/Scripts:${PATH}"

COPY --from=effectorp1_builder "${EFFECTORP1_PREFIX}" "${EFFECTORP1_PREFIX}"
COPY --from=effectorp1_builder "${APT_REQUIREMENTS_FILE}" /build/apt/effectorp1.txt

ARG WEKA_36_VERSION
ARG WEKA_36_PREFIX_ARG
ENV WEKA_36_PREFIX="${WEKA_36_PREFIX_ARG}"
ENV WEKA_36_JAR="${WEKA_36_PREFIX}/weka.jar"
LABEL weka.version="${WEKA_VERSION}"

ENV PATH="${WEKA_36_PREFIX}:${PATH}"

COPY --from=weka_builder "${WEKA_36_PREFIX}" "${WEKA_36_PREFIX}"
COPY --from=weka_builder "${APT_REQUIREMENTS_FILE}" /build/apt/weka36.txt


ARG EMBOSS_VERSION
ARG EMBOSS_PREFIX_ARG
ENV EMBOSS_PREFIX="${EMBOSS_PREFIX_ARG}"
LABEL emboss.version="${EMBOSS_VERSION}"

ENV PATH="${EMBOSS_PREFIX}/bin:${PATH}"
ENV CPATH="${EMBOSS_PREFIX}/include:${CPATH}"
ENV LIBRARY_PATH="${EMBOSS_PREFIX}/lib:${LIBRARY_PATH}"
ENV LD_LIBRARY_PATH="${EMBOSS_PREFIX}/lib:${LD_LIBRARY_PATH}"

COPY --from=emboss_builder "${EMBOSS_PREFIX}" "${EMBOSS_PREFIX}"
COPY --from=emboss_builder "${APT_REQUIREMENTS_FILE}" /build/apt/emboss.txt


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
