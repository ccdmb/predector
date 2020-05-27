#!/usr/bin/env bash

set -eux

PKG_NAME_UPPER="${PKG_NAME^^}"
PKG_VERSION_NODOT="${PKG_VERSION//./_}"

EFFECTORP2_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

mkdir -p "${EFFECTORP2_DIR}"
mkdir -p "${PREFIX}/bin"

cp -r Scripts "${EFFECTORP2_DIR}"
cp *.txt "${EFFECTORP2_DIR}"
cp *.md "${EFFECTORP2_DIR}"
chmod -R a+r "${EFFECTORP2_DIR}"
chmod a+x "${EFFECTORP2_DIR}/Scripts/"{"EffectorP.py","weka-3-8-1/weka.jar"}


ln -s "${EFFECTORP2_DIR}/Scripts/EffectorP.py" "${PREFIX}/bin/EffectorP.py"
ln -s "${EFFECTORP2_DIR}/Scripts/EffectorP.py" "${PREFIX}/bin/EffectorP2.py"
