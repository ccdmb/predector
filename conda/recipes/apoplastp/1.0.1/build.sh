#!/usr/bin/env bash

set -eux

PKG_NAME_UPPER="${PKG_NAME^^}"
PKG_VERSION_NODOT="${PKG_VERSION//./_}"

APOPLASTP_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

mkdir -p "${APOPLASTP_DIR}"
mkdir -p "${PREFIX}/bin"

cp -r Scripts "${APOPLASTP_DIR}"
cp *.txt "${APOPLASTP_DIR}"
cp *.md "${APOPLASTP_DIR}"

ln -s "${APOPLASTP_DIR}/Scripts/ApoplastP.py" "${PREFIX}/bin/ApoplastP.py"
