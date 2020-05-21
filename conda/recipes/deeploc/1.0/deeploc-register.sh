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
    echo " install DeepLoc directly. To complete the installation you must "
    echo " download a licensed copy from DTU: "
    echo "     https://services.healthtech.dtu.dk/services/DeepLoc-${PKG_VERSION}/9-Downloads.php# "
    echo " and run (after installing this package):"
    echo "     $(basename ${0}) /path/to/deeploc-${PKG_VERSION}.All.tar.gz"
    echo " This will copy ${PKG_NAME} into your conda environment."
}


function print_usage(){
    echo " Usage: $(basename ${0}) /path/to/deeploc-${PKG_VERSION}.All.tar.gz"
}


# Might need to check the version


if [[ "$#" -lt 1 ]]
then
    if ! $(${TARGET_DIR}/deeploc -h > /dev/null 2>&1)
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

rm "${ENV_PREFIX}/bin/deeploc"

cp -r "${WORKDIR}/${EXTRACTED_DIR_CALLED}" "${TARGET_DIR}/src"
cd "${TARGET_DIR}/src"

# Correct source files give version 1.0 this is to keep it consistent.
sed -i 's/version=\'0.1\'/version="1.0"/' ./setup.py
pip install --no-deps --upgrade --force-reinstall --compile --prefix "${ENV_PREFIX}" .

rm -rf -- "${WORKDIR}"
