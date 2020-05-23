#!/usr/bin/env bash

set -eu

TARGET_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

"${TARGET_DIR}/unregister.sh" "${TARGET_DIR}"
