ARG VERSION=1.2.0-beta
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

COPY "${SIGNALP3}" /tmp/onbuild/
COPY "${SIGNALP4}" /tmp/onbuild/
COPY "${SIGNALP5}" /tmp/onbuild/
COPY "${SIGNALP6}" /tmp/onbuild/
COPY "${TARGETP2}" /tmp/onbuild/
COPY "${DEEPLOC}" /tmp/onbuild/
COPY "${PHOBIUS}" /tmp/onbuild/
COPY "${TMHMM}" /tmp/onbuild/

# CONDA_PREFIX should be set by the base container.
RUN echo \
 && signalp3-register "/tmp/onbuild/$(basename "${SIGNALP3}")" \
 && echo \
 && signalp4-register "/tmp/onbuild/$(basename "${SIGNALP4}")" \
 && echo \
 && signalp5-register "/tmp/onbuild/$(basename "${SIGNALP5}")" \
 && echo \
 && signalp6-register "/tmp/onbuild/$(basename "${SIGNALP6}")" \
 && echo \
 && targetp2-register "/tmp/onbuild/$(basename "${TARGETP2}")" \
 && echo \
 && deeploc-register "/tmp/onbuild/$(basename "${DEEPLOC}")" \
 && echo \
 && phobius-register "/tmp/onbuild/$(basename "${PHOBIUS}")" \
 && echo \
 && tmhmm2-register "/tmp/onbuild/$(basename "${TMHMM}")" \
 && echo \
 && rm -rf -- /tmp/onbuild
