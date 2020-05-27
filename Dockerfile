ARG VERSION=0.0.1-dev.2
FROM "predector/predector-base:${VERSION}"

LABEL description="Docker image containing all requirements for the predector pipeline"

ARG SIGNALP3
ARG SIGNALP4
ARG SIGNALP5
ARG TARGETP2
ARG DEEPLOC
ARG PHOBIUS
ARG TMHMM

RUN mkdir -p /tmp/onbuild

COPY "${SIGNALP3}" /tmp/onbuild/
COPY "${SIGNALP4}" /tmp/onbuild/
COPY "${SIGNALP5}" /tmp/onbuild/
COPY "${TARGETP2}" /tmp/onbuild/
COPY "${DEEPLOC}" /tmp/onbuild/
COPY "${PHOBIUS}" /tmp/onbuild/
COPY "${TMHMM}" /tmp/onbuild/

# CONDA_PREFIX should be set by the base container.
RUN signalp3-register "/tmp/onbuild/$(basename "${SIGNALP3}")" \
 && signalp4-register "/tmp/onbuild/$(basename "${SIGNALP4}")" \
 && signalp5-register "/tmp/onbuild/$(basename "${SIGNALP5}")" \
 && targetp2-register "/tmp/onbuild/$(basename "${TARGETP2}")" \
 && deeploc-register "/tmp/onbuild/$(basename "${DEEPLOC}")" \
 && phobius-register "/tmp/onbuild/$(basename "${PHOBIUS}")" \
 && tmhmm2-register "/tmp/onbuild/$(basename "${TMHMM}")" \
 && rm -rf -- /tmp/onbuild

