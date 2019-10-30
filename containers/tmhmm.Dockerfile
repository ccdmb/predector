ARG IMAGE
ARG FFINDEX_IMAGE

FROM "${FFINDEX_IMAGE}" as ffindex_builder

FROM "${IMAGE}"

ARG TMHMM_VERSION
ARG TMHMM_PREFIX_ARG
ARG TMHMM_TAR
ENV TMHMM_PREFIX="${TMHMM_PREFIX_ARG}"
LABEL tmhmm.version="${TMHMM_VERSION}"

ENV PATH="${TMHMM_PREFIX}/bin:${PATH}"

COPY "${TMHMM_TAR}" /tmp/tmhmm.tar.gz


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


WORKDIR /tmp
RUN  set -eu \
  && . /build/base.sh \
  && add_runtime_dep perl \
  && apt-get update \
  && apt_install_from_file "${APT_REQUIREMENTS_FILE}" \
  && apt_install_from_file /build/apt/*.txt \
  && rm -rf /var/lib/apt/lists/* \
  && tar xf tmhmm.tar.gz \
  && rm tmhmm.tar.gz \
  && mkdir -p "${TMHMM_PREFIX%/*}" \
  && mv tmhmm* "${TMHMM_PREFIX}" \
  && sed -i "s~/usr/local/bin/perl~/usr/bin/env perl~" "${TMHMM_PREFIX}/bin/tmhmm" \
  && sed -i "s~/usr/local/bin/perl -w~/usr/bin/env -S perl -w~" "${TMHMM_PREFIX}/bin/tmhmmformat.pl" \
  && ln -sf "${TMHMM_PREFIX}/bin/tmhmm" "${TMHMM_PREFIX}/bin/tmhmm-${TMHMM_VERSION}" \
  && ln -sf "${TMHMM_PREFIX}/bin/tmhmmformat.pl" "${TMHMM_PREFIX}/bin/tmhmmformat-${TMHMM_VERSION}.pl" \
  && cat /build/apt/*.txt >> "${APT_REQUIREMENTS_FILE}"

WORKDIR /
