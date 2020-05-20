#!/usr/bin/env bash

set -eux

PKG_NAME_UPPER="${PKG_NAME^^}"
PKG_VERSION_NODOT="${PKG_VERSION//./_}"

EFFECTORP1_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

mkdir -p "${EFFECTORP1_DIR}"
mkdir -p "${PREFIX}/bin"

cp -r Scripts "${EFFECTORP1_DIR}"
cp *.txt "${EFFECTORP1_DIR}"

ln -s "${EFFECTORP1_DIR}/Scripts/EffectorP.py" "${PREFIX}/bin/EffectorP.py"
ln -s "${EFFECTORP1_DIR}/Scripts/EffectorP.py" "${PREFIX}/bin/EffectorP1.py"
