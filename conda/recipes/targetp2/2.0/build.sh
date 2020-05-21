#!/usr/bin/env bash

set -eux

PKG_NAME_UPPER="${PKG_NAME^^}"
PKG_VERSION_NODOT="${PKG_VERSION//./_}"

TARGET_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

mkdir -p "${TARGET_DIR}"
mkdir -p "${TARGET_DIR}/bin"
mkdir -p "${TARGET_DIR}/lib"
mkdir -p "${PREFIX}/bin"

# This is just so that conda doesn't delete the empty folder.
touch "${TARGET_DIR}/lib/libtensorflow.so"

cp "${RECIPE_DIR}/targetp-placeholder.sh" "${TARGET_DIR}/bin/targetp"
chmod a+x "${TARGET_DIR}/bin/targetp"
ln -s "${TARGET_DIR}/bin/targetp" "${PREFIX}/bin/targetp"
ln -s "${TARGET_DIR}/bin/targetp" "${PREFIX}/bin/targetp2"
ln -rs "${TARGET_DIR}/bin/targetp" "${TARGET_DIR}/bin/targetp2"


REGISTER_FILE="${TARGET_DIR}/targetp-register.sh"

echo "#!/usr/bin/env bash" > "${REGISTER_FILE}"
echo "set -eu" >> "${REGISTER_FILE}"
echo "PKG_NAME=${PKG_NAME}" >> "${REGISTER_FILE}"
echo "PKG_VERSION=${PKG_VERSION}" >> "${REGISTER_FILE}"
echo "PKG_BUILDNUM=${PKG_BUILDNUM}" >> "${REGISTER_FILE}"

cat "${RECIPE_DIR}/targetp-register.sh" >> "${REGISTER_FILE}"

chmod a+x "${REGISTER_FILE}"
ln -s "${REGISTER_FILE}" "${PREFIX}/bin/targetp2-register"
