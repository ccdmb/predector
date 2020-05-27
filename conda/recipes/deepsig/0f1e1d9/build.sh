#!/usr/bin/env bash

set -eux

PKG_NAME_UPPER="${PKG_NAME^^}"
PKG_VERSION_NODOT="${PKG_VERSION//./_}"

DEEPSIG_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

mkdir -p "${DEEPSIG_DIR}"
mkdir -p "${PREFIX}/bin"

cp -r deepsiglib "${DEEPSIG_DIR}"
cp -r models "${DEEPSIG_DIR}"
cp -r testdata "${DEEPSIG_DIR}"
cp -r tools "${DEEPSIG_DIR}"
cp LICENSE "${DEEPSIG_DIR}"
cp README.md "${DEEPSIG_DIR}"

cp deepsig.py "${DEEPSIG_DIR}"

chmod -R a+r "${DEEPSIG_DIR}"
chmod a+x "${DEEPSIG_DIR}/"{"deepsig.py","tools/biocrf-static"}

ln -s "${DEEPSIG_DIR}/deepsig.py" "${PREFIX}/bin/deepsig.py"
