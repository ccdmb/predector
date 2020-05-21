#!/usr/bin/env bash

set -eux

PKG_NAME_UPPER="${PKG_NAME^^}"
PKG_VERSION_NODOT="${PKG_VERSION//./_}"

TARGET_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

mkdir -p "${TARGET_DIR}"
mkdir -p "${PREFIX}/bin"

# This is just so that conda doesn't delete the empty folder.

cp "${RECIPE_DIR}/deeploc-placeholder.sh" "${TARGET_DIR}/bin/deeploc"
chmod a+x "${TARGET_DIR}/bin/signalp"
ln -s "${TARGET_DIR}/bin/deeploc" "${PREFIX}/bin/deeploc"


REGISTER_FILE="${TARGET_DIR}/deeploc-register.sh"

echo "#!/usr/bin/env bash" > "${REGISTER_FILE}"
echo "set -eu" >> "${REGISTER_FILE}"
echo "PKG_NAME=${PKG_NAME}" >> "${REGISTER_FILE}"
echo "PKG_VERSION=${PKG_VERSION}" >> "${REGISTER_FILE}"
echo "PKG_BUILDNUM=${PKG_BUILDNUM}" >> "${REGISTER_FILE}"

cat "${RECIPE_DIR}/deeploc-register.sh" >> "${REGISTER_FILE}"

chmod a+x "${REGISTER_FILE}"
ln -s "${REGISTER_FILE}" "${PREFIX}/bin/deeploc-register"
