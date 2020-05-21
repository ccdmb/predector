#!/usr/bin/env bash

TARGET_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

rm -f "${TARGET_DIR}/"{signalp-5.0b.readme,signalp.1}
rm -rf -- "${TARGET_DIR}/test"
rm -f "${TARGET_DIR}/lib/"{libtensorflow.so,libtensorflow_framework.so}

rm -f "${TARGET_DIR}/bin/signalp"

mv "${TARGET_DIR}/signalp-placeholder.sh" "${TARGET_DIR}/bin/signalp"
mv "${TARGET_DIR}/libtensorflow-placeholder.so" "${TARGET_DIR}/lib/libtensorflow.so"
