#!/usr/bin/env bash

set -eux

PKG_NAME_UPPER="${PKG_NAME^^}"
PKG_VERSION_NODOT="${PKG_VERSION//./_}"

TARGET_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

mkdir -p "${TARGET_DIR}"
mkdir -p "${PREFIX}/bin"


cp "${RECIPE_DIR}/phobius.pl.patch" "${TARGET_DIR}/phobius.pl.patch"
cp "${RECIPE_DIR}/phobius-placeholder.sh" "${TARGET_DIR}/phobius.pl"
chmod a+x "${TARGET_DIR}/phobius.pl"
ln -s "${TARGET_DIR}/phobius.pl" "${PREFIX}/bin/phobius.pl"


REGISTER_FILE="${TARGET_DIR}/phobius-register.sh"

echo "#!/usr/bin/env bash" > "${REGISTER_FILE}"
echo "set -eu" >> "${REGISTER_FILE}"
echo "PKG_NAME=${PKG_NAME}" >> "${REGISTER_FILE}"
echo "PKG_VERSION=${PKG_VERSION}" >> "${REGISTER_FILE}"
echo "PKG_BUILDNUM=${PKG_BUILDNUM}" >> "${REGISTER_FILE}"

cat "${RECIPE_DIR}/phobius-register.sh" >> "${REGISTER_FILE}"

chmod a+x "${REGISTER_FILE}"
ln -s "${REGISTER_FILE}" "${PREFIX}/bin/phobius-register"
