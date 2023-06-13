#!/usr/bin/env bash

set -eux

# Where can users download the source from?
DOWNLOAD_URL=https://services.healthtech.dtu.dk/services/DeepLoc-2.0/9-Downloads.php#

# What is the expected source tarball named?
TAR_FILE=deeploc-1.0.All.tar.gz

# What is the main executable of the program? e.g. signalp
EXE=deeploc2

# What should be the executable name with a version e.g. signalp5
VEXE=deeploc2

# Where is the actual file relative to the basedir in the share folder?
# This will only need to be changed if your program folder uses a subdirectory under the target directory.
# e.g. "bin/${EXE}"
PEXE="${EXE}"

# This should generally be fine as is.
PVEXE="$(dirname "${PEXE}")/${VEXE}"


## You shouldn't need to change anything below this line.

TARGET_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

mkdir -p "${TARGET_DIR}"
mkdir -p "$(dirname "${TARGET_DIR}/${PEXE}")"
mkdir -p "${PREFIX}/bin"

find "${RECIPE_DIR}" -name '*.patch' -exec cp {} "${TARGET_DIR}" \;

INSTALL_COMPLETE_MESSAGE="\
${PKG_NAME} ${PKG_VERSION} has not been installed yet.

Due to license restrictions, this recipe cannot distribute ${PKG_NAME} directly.
Please download ${TAR_FILE} from:
${DOWNLOAD_URL}

and run the following command to complete the installation:
\$ ${VEXE}-register ${TAR_FILE}

This will copy ${PKG_NAME} into your conda environment."


## Setup the placeholder script

echo "#!/usr/bin/env bash" > "${TARGET_DIR}/${PEXE}"
echo "echo '${INSTALL_COMPLETE_MESSAGE}'" >> "${TARGET_DIR}/${PEXE}"
echo "exit 1" >> "${TARGET_DIR}/${PEXE}"
cp "${TARGET_DIR}/${PEXE}" "${TARGET_DIR}/placeholder.sh"
chmod a+rx "${TARGET_DIR}/${PEXE}"
chmod a+rx "${TARGET_DIR}/placeholder.sh"

#ln -s "${TARGET_DIR}/${PEXE}" "${PREFIX}/bin/${EXE}"
#ln -s "${TARGET_DIR}/${PEXE}" "${PREFIX}/bin/${VEXE}"

# This is necessary because some binaries hard code to the symlink filename.
#ln -s "${TARGET_DIR}/${PEXE}" "${TARGET_DIR}/${PVEXE}"


## Setup the script that will actually install things for us.

REGISTER_FILE="${TARGET_DIR}/register.sh"

echo "#!/usr/bin/env bash" > "${REGISTER_FILE}"
echo "set -eu" >> "${REGISTER_FILE}"
echo "PKG_NAME=${PKG_NAME}" >> "${REGISTER_FILE}"
echo "PKG_VERSION=${PKG_VERSION}" >> "${REGISTER_FILE}"
echo "PKG_BUILDNUM=${PKG_BUILDNUM}" >> "${REGISTER_FILE}"
echo "TAR_FILE=${TAR_FILE}" >> "${REGISTER_FILE}"
echo "DOWNLOAD_URL=${DOWNLOAD_URL}" >> "${REGISTER_FILE}"
echo "EXE=${EXE}" >> "${REGISTER_FILE}"
echo "VEXE=${VEXE}" >> "${REGISTER_FILE}"
echo "PEXE=${PEXE}" >> "${REGISTER_FILE}"
echo "PVEXE=${PVEXE}" >> "${REGISTER_FILE}"
echo "INSTALL_COMPLETE_MESSAGE='${INSTALL_COMPLETE_MESSAGE}'" >> "${REGISTER_FILE}"
cat "${RECIPE_DIR}/register-base.sh" >> "${REGISTER_FILE}"
cat "${RECIPE_DIR}/register.sh" >> "${REGISTER_FILE}"
echo 'touch ${TARGET_DIR}/completed' >> "${REGISTER_FILE}"
cat "${RECIPE_DIR}/register-test.sh" >> "${REGISTER_FILE}"
chmod a+rx "${REGISTER_FILE}"
ln -s "${REGISTER_FILE}" "${PREFIX}/bin/${VEXE}-register"


## Setup the script that removes the things we installed

UNREGISTER="${TARGET_DIR}/unregister.sh"
echo '#!/usr/bin/env bash' > "${UNREGISTER}"
echo "set -eu" >> "${UNREGISTER}"
echo "PKG_NAME=${PKG_NAME}" >> "${UNREGISTER}"
echo "PKG_VERSION=${PKG_VERSION}" >> "${UNREGISTER}"
echo "PKG_BUILDNUM=${PKG_BUILDNUM}" >> "${UNREGISTER}"
echo 'if [ -z "${1:-}" ]
then
  TARGET_DIR="$(dirname "${0}")"
else
  TARGET_DIR="${1}"
fi
' >> "${UNREGISTER}"
echo "TAR_FILE=${TAR_FILE}" >> "${UNREGISTER}"
echo "DOWNLOAD_URL=${DOWNLOAD_URL}" >> "${UNREGISTER}"
echo "EXE=${EXE}" >> "${UNREGISTER}"
echo "VEXE=${VEXE}" >> "${UNREGISTER}"
echo "PEXE=${PEXE}" >> "${UNREGISTER}"
echo "PVEXE=${PVEXE}" >> "${UNREGISTER}"

cat "${RECIPE_DIR}/unregister.sh" >> "${UNREGISTER}"
echo 'mkdir -p "$(dirname "${TARGET_DIR}/${PEXE}")"' >> "${UNREGISTER}"
echo '[ -f "${TARGET_DIR}/placeholder.sh" ] && cp "${TARGET_DIR}/placeholder.sh" "${TARGET_DIR}/${PEXE}"' >> "${UNREGISTER}"
echo 'rm -f "${TARGET_DIR}/completed"' >> "${UNREGISTER}"

chmod a+rx "${UNREGISTER}"
