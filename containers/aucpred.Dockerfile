FROM debian:buster-20191014-slim

ENV AUCPRED_VERSION="1.03"
ENV AUCPRED_PREFIX="/opt/aucpred/${AUCPRED_VERSION}"

WORKDIR /tmp

COPY sources/AUCpreD_v1.03_release.tar.gz /tmp

RUN  set -eu \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
       build-essential \
       perl \
       bash \
       gawk \
       python3 \
       ca-certificates \
  && rm -rf /var/lib/apt/lists/* \
  && tar -zxf AUCpreD_v1.03_release.tar.gz \
  && cd AUCpreD_v1.03_release \
  && ./setup.pl

ENV PATH="${AUCPRED_PREFIX}/bin:${AUCPRED_PREFIX}:${AUCPRED_PREFIX}/util:${PATH}"
