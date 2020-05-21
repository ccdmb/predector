# Note: $PKG_* variables are inserted above this line by the build script.


# This file based on recipe for Gatk3 in bioconda.
# https://github.com/bioconda/bioconda-recipes/blob/master/recipes/gatk


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
    echo
    echo " Due to license restrictions, this recipe cannot distribute and "
    echo " install TargetP directly. To complete the installation you must "
    echo " download a licensed copy from DTU: "
    echo "     https://services.healthtech.dtu.dk/services/TargetP-${PKG_VERSION}/9-Downloads.php# "
    echo " and run (after installing this package):"
    echo "     $(basename ${0}) /path/to/targetp-${PKG_VERSION}.Linux.tar.gz"
    echo " This will copy ${PKG_NAME} into your conda environment."
}


function print_usage(){
    echo " Usage: $(basename ${0}) /path/to/targetp-${PKG_VERSION}.Linux.tar.gz"
}


# Might need to check the version


if [[ "$#" -lt 1 ]]
then
    if ! $(${TARGET_DIR}/targetp -h > /dev/null 2>&1)
    then
        echo " It looks ${PKG_NAME} hasn't been installed yet."
        echo
        print_usage
        print_license_notice
        exit 1
    else
        echo " It looks like ${PKG_NAME} is already installed in your environment."
        exit 0
    fi
fi

ARCHIVE="${1}"

EXTRACTED_DIR_CALLED="$(basename $(tar -tf "${ARCHIVE}" | head -n 1))"

WORKDIR="${TMPDIR:-/tmp}/tmp$$"
mkdir -p "${WORKDIR}"
tar --directory=${WORKDIR} -xf "${ARCHIVE}"

cd "${WORKDIR}/${EXTRACTED_DIR_CALLED}"

mkdir -p "${TARGET_DIR}/bin"
mkdir -p "${TARGET_DIR}/lib"

mv "${TARGET_DIR}/bin/targetp" "${TARGET_DIR}/targetp-placeholder.sh"
mv "${TARGET_DIR}/lib/libtensorflow.so" "${TARGET_DIR}/libtensorflow-placeholder.so"

mv bin/* "${TARGET_DIR}/bin"
mv lib/* "${TARGET_DIR}/lib"

rm -rf -- bin lib
mv ./* "${TARGET_DIR}"

cd "${TARGET_DIR}"
rm -rf -- "${WORKDIR}"
