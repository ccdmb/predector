#!/usr/bin/env bash

set -eux

PKG_NAME_UPPER="${PKG_NAME^^}"
PKG_VERSION_NODOT="${PKG_VERSION//./_}"

TARGET_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

mkdir -p "${TARGET_DIR}"
mkdir -p "${TARGET_DIR}/bin"
mkdir -p "${PREFIX}/bin"


cp "${RECIPE_DIR}/tmhmm-placeholder.sh" "${TARGET_DIR}/bin/tmhmm"
cp "${RECIPE_DIR}/tmhmm-placeholder.sh" "${TARGET_DIR}/bin/tmhmmformat.pl"

chmod a+x "${TARGET_DIR}/bin/tmhmm"
chmod a+x "${TARGET_DIR}/bin/tmhmmformat.pl"
ln -sr "${TARGET_DIR}/bin/tmhmm" "${PREFIX}/bin/tmhmm"
ln -sr "${TARGET_DIR}/bin/tmhmmformat.pl" "${PREFIX}/bin/tmhmmformat.pl"

cp "${RECIPE_DIR}/tmhmm.patch" "${TARGET_DIR}/tmhmm.patch"

REGISTER_FILE="${TARGET_DIR}/tmhmm-register.sh"

echo "#!/usr/bin/env bash" > "${REGISTER_FILE}"
echo "set -eu" >> "${REGISTER_FILE}"
echo "PKG_NAME=${PKG_NAME}" >> "${REGISTER_FILE}"
echo "PKG_VERSION=${PKG_VERSION}" >> "${REGISTER_FILE}"
echo "PKG_BUILDNUM=${PKG_BUILDNUM}" >> "${REGISTER_FILE}"

cat "${RECIPE_DIR}/tmhmm-register.sh" >> "${REGISTER_FILE}"

chmod a+x "${REGISTER_FILE}"
ln -s "${REGISTER_FILE}" "${PREFIX}/bin/tmhmm-register"
