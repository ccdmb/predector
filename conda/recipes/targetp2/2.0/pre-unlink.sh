#!/usr/bin/env bash

TARGET_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

rm -f "${TARGET_DIR}/targetp-2.0.readme"
rm -rf -- "${TARGET_DIR}/test"
rm -f "${TARGET_DIR}/lib/"{libtensorflow.so,libtensorflow_framework.so}

rm -f "${TARGET_DIR}/bin/targetp"

mv "${TARGET_DIR}/targetp-placeholder.sh" "${TARGET_DIR}/bin/targetp"
mv "${TARGET_DIR}/libtensorflow-placeholder.so" "${TARGET_DIR}/lib/libtensorflow.so"
