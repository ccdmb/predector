#!/usr/bin/env bash

TARGET_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

# If the source folder isn't empty
if [ -d "${TARGET_DIR}/src" ] && [ $(ls -A "${TARGET_DIR}/src") ]
then
    cd "${TARGET_DIR}/src"
    pip uninstall --yes DeepLoc
fi

rm -rf -- "${TARGET_DIR}/src"

REGISTER_FILE="${TARGET_DIR}/deeploc-register.sh"
ln -sfr "${REGISTER_FILE}" "${PREFIX}/bin/deeploc-register"
