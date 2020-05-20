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

    SIGNALP_DIR="$( cd -P "$( dirname "${SOURCE}" )" && pwd )"
    ENV_PREFIX="$(dirname $(dirname ${SIGNALP_DIR}))"

    unset SOURCE
    unset DIR
else
    ENV_PREFIX="${CONDA_PREFIX}"
    SIGNALP_DIR="${ENV_PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"
fi

function print_license_notice(){
    echo
    echo " Due to license restrictions, this recipe cannot distribute and "
    echo " install SignalP directly. To complete the installation you must "
    echo " download a licensed copy from DTU: "
    echo "     https://services.healthtech.dtu.dk/services/SignalP-4.1g/9-Downloads.php# "
    echo " and run (after installing this package):"
    echo "     $(basename ${0}) /path/to/SignalP-4.1g.Linux.tar.gz"
    echo " This will copy ${PKG_NAME} into your conda environment."
}


function print_usage(){
    echo " Usage: $(basename ${0}) /path/to/SignalP-4.1g.Linux.tar.gz"
}


# Might need to check the version


if [[ "$#" -lt 1 ]]
then
    if ! $(${SIGNALP_DIR}/signalp -h > /dev/null 2>&1)
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

chmod -R a+rw ./*

cp -r ./* "${SIGNALP_DIR}"

cd "${SIGNALP_DIR}"
rm -rf -- "${WORKDIR}"

patch signalp signalp.patch

# I don't know enough perl to make it resolve the relative symlink, so
# continuing to hard code the path is the best I can do.
sed -i "s~/usr/opt/www/pub/CBS/services/SignalP-4.1/signalp-4.1~${SIGNALP_DIR}~" ./signalp
