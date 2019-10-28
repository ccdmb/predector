ARG IMAGE="darcyabjones/base"
ARG WEKA_36_IMAGE
ARG EMBOSS_IMAGE
ARG FFINDEX_IMAGE

FROM "${WEKA_36_IMAGE}" as weka_builder
FROM "${EMBOSS_IMAGE}" as emboss_builder
FROM "${FFINDEX_IMAGE}" as ffindex_builder

FROM "${IMAGE}" as localizer_builder

ARG LOCALIZER_VERSION="1.0.4"
ARG LOCALIZER_URL="http://localizer.csiro.au/LOCALIZER_1.0.4.tar.gz"
ARG LOCALIZER_PREFIX_ARG="/opt/localizer/${LOCALIZER_VERSION}"
ENV LOCALIZER_PREFIX="${LOCALIZER_PREFIX_ARG}"
ENV PATH="${LOCALIZER_PREFIX}:${PATH}"

ARG WEKA_36_VERSION
ARG WEKA_36_PREFIX_ARG="/opt/weka/${WEKA_36_VERSION}"
ENV WEKA_36_PREFIX="${WEKA_36_PREFIX_ARG}"

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
  && wget -O localizer.tar.gz "${LOCALIZER_URL}" \
  && tar xf localizer.tar.gz \
  && rm localizer.tar.gz \
  && mkdir -p "${LOCALIZER_PREFIX%/*}" \
  && mv LOCALIZER* "${LOCALIZER_PREFIX}" \
  && rm ${LOCALIZER_PREFIX}/Scripts/*.tar.gz \
  && rm ${LOCALIZER_PREFIX}/Scripts/*.zip \
  && ln -sf "${WEKA_36_PREFIX}" "${LOCALIZER_PREFIX}/Scripts/weka-3-6-12" \
  && chmod a+x "${LOCALIZER_PREFIX}/Scripts/LOCALIZER.py" \
  && sed -i "s~/usr/bin/python~/usr/bin/env python~" "${LOCALIZER_PREFIX}/Scripts/LOCALIZER.py" \
  && sed -i "s~SCRIPT_PATH + '/EMBOSS-6.5.7/emboss/'~'${EMBOSS_PREFIX}/bin/'~" "${LOCALIZER_PREFIX}/Scripts/LOCALIZER.py" \
  && ln -sf "${LOCALIZER_PREFIX}/Scripts/LOCALIZER.py" "${LOCALIZER_PREFIX}/Scripts/LOCALIZER-${LOCALIZER_VERSION}.py" \
  && add_runtime_dep perl python python-biopython


FROM "${IMAGE}"

ARG LOCALIZER_VERSION="1.0.4"
ARG LOCALIZER_PREFIX_ARG="/opt/localizer/${LOCALIZER_VERSION}"
ENV LOCALIZER_PREFIX="${LOCALIZER_PREFIX_ARG}"
LABEL localizer.version="${LOCALIZER_VERSION}"

ENV PATH="${LOCALIZER_PREFIX}/Scripts:${PATH}"

COPY --from=localizer_builder "${LOCALIZER_PREFIX}" "${LOCALIZER_PREFIX}"
COPY --from=localizer_builder "${APT_REQUIREMENTS_FILE}" /build/apt/localizer.txt

ARG WEKA_36_VERSION
ARG WEKA_36_PREFIX_ARG="/opt/weka/${WEKA_36_VERSION}"
ENV WEKA_36_PREFIX="${WEKA_36_PREFIX_ARG}"
ENV WEKA_36_JAR="${WEKA_36_PREFIX}/weka.jar"
LABEL weka.version="${WEKA_VERSION}"

ENV PATH="${WEKA_36_PREFIX}:${PATH}"

COPY --from=weka_builder "${WEKA_36_PREFIX}" "${WEKA_36_PREFIX}"
COPY --from=weka_builder "${APT_REQUIREMENTS_FILE}" /build/apt/weka36.txt


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
