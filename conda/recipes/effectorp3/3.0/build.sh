#!/usr/bin/env bash

set -eux

PKG_NAME_UPPER="${PKG_NAME^^}"
PKG_VERSION_NODOT="${PKG_VERSION//./_}"

EFFECTORP3_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

mkdir -p "${EFFECTORP3_DIR}"
mkdir -p "${PREFIX}/bin"

unzip weka-3-8-4.zip
cp -r weka-3.8.4 ${EFFECTORP3_DIR}

cp *.txt *.py *.md *.fasta "${EFFECTORP3_DIR}"
cp -r TrainingData* "${EFFECTORP3_DIR}"
chmod -R a+r "${EFFECTORP3_DIR}"
chmod a+x "${EFFECTORP3_DIR}/"{"EffectorP.py","weka-3-8-4/weka.jar"}


ln -s "${EFFECTORP3_DIR}/EffectorP.py" "${PREFIX}/bin/EffectorP.py"
ln -s "${EFFECTORP3_DIR}/EffectorP.py" "${PREFIX}/bin/EffectorP3.py"
