ARG IMAGE="darcyabjones/base"

FROM "${IMAGE}" as builder

RUN  set -eu \
  && DEBIAN_FRONTEND=noninteractive \
  && . /build/base.sh \
  && add_runtime_dep python3 python3-pip python3-wheel python3-biopython python3-intervaltree python3-pandas python3-setuptools \
  && apt-get update \
  && apt_install_from_file "${APT_REQUIREMENTS_FILE}" \
  && rm -rf /var/lib/apt/lists/* \
  && python3 -m pip install python-baseconv
