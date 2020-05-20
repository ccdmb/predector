#!/usr/bin/env bash

set -eux

PKG_NAME_UPPER="${PKG_NAME^^}"
PKG_VERSION_NODOT="${PKG_VERSION//./_}"

SIGNALP_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

mkdir -p "${SIGNALP_DIR}"
mkdir -p "${PREFIX}/bin"


cp "${RECIPE_DIR}/signalp.patch" "${SIGNALP_DIR}/signalp.patch"
cp "${RECIPE_DIR}/signalp-placeholder.sh" "${SIGNALP_DIR}/signalp"
chmod a+x "${SIGNALP_DIR}/signalp"
ln -s "${SIGNALP_DIR}/signalp" "${PREFIX}/bin/signalp"
ln -s "${SIGNALP_DIR}/signalp" "${PREFIX}/bin/signalp4"


REGISTER_FILE="${SIGNALP_DIR}/signalp-register.sh"

echo "#!/usr/bin/env bash" > "${REGISTER_FILE}"
echo "set -eu" >> "${REGISTER_FILE}"
echo "PKG_NAME=${PKG_NAME}" >> "${REGISTER_FILE}"
echo "PKG_VERSION=${PKG_VERSION}" >> "${REGISTER_FILE}"
echo "PKG_BUILDNUM=${PKG_BUILDNUM}" >> "${REGISTER_FILE}"

cat "${RECIPE_DIR}/signalp-register.sh" >> "${REGISTER_FILE}"

chmod a+x "${REGISTER_FILE}"
ln -s "${REGISTER_FILE}" "${PREFIX}/bin/signalp4-register"
