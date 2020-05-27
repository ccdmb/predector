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

chmod -R a+r "${APOPLASTP_DIR}"
chmod a+x "${APOPLASTP_DIR}/Scripts/"{"ApoplastP.py","weka-3-8-1/weka.jar"}

ln -s "${APOPLASTP_DIR}/Scripts/ApoplastP.py" "${PREFIX}/bin/ApoplastP.py"
