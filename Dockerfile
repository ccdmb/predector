ARG VERSION=1.2.4
FROM "predector/predector-base:${VERSION}"

LABEL description="Docker image containing all requirements for the predector pipeline"

ARG SIGNALP3
ARG SIGNALP4
ARG SIGNALP5
ARG SIGNALP6
ARG TARGETP2
ARG DEEPLOC
ARG PHOBIUS
ARG TMHMM

RUN mkdir -p /tmp/onbuild

# Anything with ":-" here should be able to handle not being installed
COPY "${SIGNALP3}" \
  "${SIGNALP4}" \
  "${SIGNALP5}" \
  ${SIGNALP6:-} \
  "${TARGETP2}" \
  "${DEEPLOC}" \
  "${PHOBIUS}" \
  "${TMHMM}" \
  /tmp/onbuild/

# CONDA_PREFIX should be set by the base container.
RUN echo \
 && signalp3-register "/tmp/onbuild/$(basename "${SIGNALP3}")" \
 && echo \
 && signalp4-register "/tmp/onbuild/$(basename "${SIGNALP4}")" \
 && echo \
 && signalp5-register "/tmp/onbuild/$(basename "${SIGNALP5}")" \
 && echo \
 && targetp2-register "/tmp/onbuild/$(basename "${TARGETP2}")" \
 && echo \
 && deeploc-register "/tmp/onbuild/$(basename "${DEEPLOC}")" \
 && echo \
 && phobius-register "/tmp/onbuild/$(basename "${PHOBIUS}")" \
 && echo \
 && tmhmm2-register "/tmp/onbuild/$(basename "${TMHMM}")" \
 && echo \
 && if [ ! -z "${SIGNALP6:-}" ]; then signalp6-register "/tmp/onbuild/$(basename "${SIGNALP6}")"; echo; fi \
 && rm -rf -- /tmp/onbuild
