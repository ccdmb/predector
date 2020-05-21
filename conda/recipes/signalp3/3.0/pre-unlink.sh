#!/usr/bin/env bash

TARGET_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

rm -f "${TARGET_DIR}/"{signalp.1,signalp-3.0.readme,syn-3.0}
rm -rf -- "${TARGET_DIR}/test"
rm -rf -- "${TARGET_DIR}/tmp"
rm -rf -- "${TARGET_DIR}/"{syn-2.0,syn-1.1,syn-1.0,syn}
rm -rf -- "${TARGET_DIR}/mod"
rm -rf -- "${TARGET_DIR}/how"
rm -rf -- "${TARGET_DIR}/hmm"
rm -rf -- "${TARGET_DIR}/bin"

mv "${TARGET_DIR}/signalp-placeholder.sh" "${TARGET_DIR}/signalp"
