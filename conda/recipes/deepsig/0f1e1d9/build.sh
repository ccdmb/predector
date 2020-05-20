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

# Delete this line.
# The script will be in the deepsig root, and the script path name is
# automatically in sys.path
cp deepsig.py "${DEEPSIG_DIR}"


ln -s "${DEEPSIG_DIR}/deepsig.py" "${PREFIX}/bin/deepsig.py"
