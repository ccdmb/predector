#!/usr/bin/env bash

set -eux

PKG_NAME_UPPER="${PKG_NAME^^}"
PKG_VERSION_NODOT="${PKG_VERSION//./_}"

LOCALIZER_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

mkdir -p "${LOCALIZER_DIR}"
mkdir -p "${PREFIX}/bin"

cp -r Scripts "${LOCALIZER_DIR}"
cp *.txt "${LOCALIZER_DIR}"
cp *.md "${LOCALIZER_DIR}"

chmod -R a+r "${LOCALIZER_DIR}"
chmod a+x "${LOCALIZER_DIR}/Scripts/"{"LOCALIZER.py","weka-3-6-12/weka.jar"}

ln -s "${LOCALIZER_DIR}/Scripts/LOCALIZER.py" "${PREFIX}/bin/LOCALIZER.py"
