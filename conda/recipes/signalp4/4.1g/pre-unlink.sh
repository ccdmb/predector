#!/usr/bin/env bash

TARGET_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

rm -f "${TARGET_DIR}/"{signalp-4.1.readme,signalp.1}
rm -rf -- "${TARGET_DIR}/test"
rm -rf -- "${TARGET_DIR}/syn"
rm -rf -- "${TARGET_DIR}/bin"
rm -rf -- "${TARGET_DIR}/lib"

mv "${TARGET_DIR}/signalp-placeholder.sh" "${TARGET_DIR}/signalp"
