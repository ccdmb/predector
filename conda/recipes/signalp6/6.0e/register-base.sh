# Note: $PKG_* variables are inserted above this line by the build script.

WORKDIR="${TMPDIR:-/tmp}/tmp$$"

function cleanup() {
  if [ ! -z "${WORKDIR:-}" ]
  then
    rm -rf -- "${WORKDIR}"
  fi
}

trap cleanup EXIT


# Use the conda env variable if we can, otherwise try to find it based
# on the path of this script.
if [ -z "${CONDA_PREFIX:-}" ]
then
    # Find original directory of bash script, resovling symlinks
    # http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in/246128#246128
    SOURCE="${BASH_SOURCE[0]}"
    while [ -h "${SOURCE}" ]; do # resolve $SOURCE until the file is no longer a symlink
        DIR="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"
        SOURCE="$(readlink "${SOURCE}")"
        [[ ${SOURCE} != /* ]] && SOURCE="${DIR}/${SOURCE}" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
    done

    TARGET_DIR="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"
    ENV_PREFIX="$(dirname $(dirname ${TARGET_DIR}))"

    unset SOURCE
    unset DIR
else
    ENV_PREFIX="${CONDA_PREFIX}"
    TARGET_DIR="${ENV_PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
fi


function print_license_notice(){
    echo "${INSTALL_COMPLETE_MESSAGE}"
}



if [[ "$#" -lt 1 ]]
then
    if [ -f "${TARGET_DIR}/completed" ]
    then
        echo "${PKG_NAME} is already installed in your environment."
        exit 0
    else
        print_license_notice
        exit 1
    fi
fi


ARCHIVE="${1}"

if [ "$(basename ${ARCHIVE})" != "${TAR_FILE}" ]
then
    echo "\
WARNING: ${ARCHIVE} filename doesn't appear to match the expected filename
         ${TAR_FILE}.
" 1>&2

    echo "\
WARNING: We'll attempt to continue the installation but you may want to
         double check that you really mean to use this file for package
         ${PKG_NAME} ${PKG_VERSION}.
" 1>&2
fi


echo "Registering source file ${ARCHIVE} for ${PKG_NAME} into conda environment at:"
echo "${TARGET_DIR}"
echo


# Remove all of the old files.
echo "Unregistering old source files if they exist."
"${TARGET_DIR}/unregister.sh" "${TARGET_DIR}"
echo
