#!/usr/bin/env bash

set -euo pipefail

ISSUES_URL="https://github.com/ccdmb/predector/issues"
MAINTAINER="Darcy Jones <darcy.ab.jones@gmail.com>"
REPOBASE="https://raw.githubusercontent.com/ccdmb/predector"

### DEFAULT PARAMETERS
VERSION=1.0.0-beta

SIGNALP3= #signalp-3.0.Linux.tar.Z
SIGNALP4= #signalp-4.1g.Linux.tar.gz
SIGNALP5= #signalp-5.0b.Linux.tar.gz
TARGETP2= #targetp-2.0.Linux.tar.gz
DEEPLOC= #deeploc-1.0.All.tar.gz
TMHMM= #tmhmm-2.0c.Linux.tar.gz
PHOBIUS= #phobius101_linux.tar.gz

# Depending on the value of ENVIRONMENT,
# NAME sets the conda environment name, docker tag, or singularity filename
# We set defaults separately
NAME=
CONDA_DEFAULTNAME="predector"
DOCKER_DEFAULTNAME="predector/predector:${VERSION}"
SINGULARITY_DEFAULTNAME="predector.sif"

# Only valid for CONDA, use this path prefix instead of a name.
CONDA_ENV_DIR=

# This sets -x
DEBUG=false

# Required argument
ENVIRONMENT=


### GET COMMAND LINE PARAMETERS

usage() {
    echo -e 'USAGE:
$ install.sh [conda|docker|singularity] \\
    -3 signalp-3.0.Linux.tar.Z \\
    -4 signalp-4.1g.Linux.tar.gz \\
    -5 signalp-5.0b.Linux.tar.gz \\
    -t targetp-2.0.Linux.tar.gz \\
    -d deeploc-1.0.All.tar.gz \\
    -m tmhmm-2.0c.Linux.tar.gz \\
    -p phobius101_linux.tar.gz

Please select only one of conda, docker, or singularity.'
}

usage_err() {
    usage
    echo -e '
Run "install.sh --help" for extended usage information.'
}


help() {
    echo -e "
This script installs the dependencies for the predector pipeline into one
of the supported runtime dependency systems (i.e. conda or a container).

To use the script, you will need:

  1. An internet connection and a posix compatible OS.
  2. conda, docker, or singularity installed
  3. The source files for the proprietary dependencies.
    - https://services.healthtech.dtu.dk/services/SignalP-3.0/9-Downloads.php#
    - https://services.healthtech.dtu.dk/services/SignalP-4.1/9-Downloads.php#
    - https://services.healthtech.dtu.dk/services/SignalP-5.0/9-Downloads.php#
    - https://services.healthtech.dtu.dk/services/TargetP-2.0/9-Downloads.php#
    - https://services.healthtech.dtu.dk/services/DeepLoc-1.0/9-Downloads.php#
    - https://services.healthtech.dtu.dk/services/TMHMM-2.0/9-Downloads.php#
    - http://software.sbc.su.se/cgi-bin/request.cgi?project=phobius

If your installation of singularity or docker requires sudo to build,
you may need to enter your root password at some point.

We can only support Conda based installations on Linux, if you are running
MacOS, Windows, or Cygwin, this script should fail if you try to install with conda.

Positional arguments:
  singularity|conda|docker  -- The environment that you want to install into or build.

Required parameters:
  -3|--signalp3  -- The path to the signalp v3 source archive.
  -4|--signalp4  -- The path to the signalp v4 source archive.
  -5|--signalp5  -- The path to the signalp v5 source archive.
  -t|--targetp2  -- The path to the signalp v5 source archive.
  -d|--deeploc   -- The path to the deeploc v1 source archive.
  -m|--tmhmm     -- The path to the tmhmm v2 source archive.
  -p|--phobius   -- The path to the phobius v1 source archive.

Optional parameters:
  -v|--version   -- The version of the pipeline that you want to
                    setup dependencies for. Note that this may not work in
                    general, and you're recommended to use the install.sh
                    script for the targeted version.
                    Default: '${VERSION}'.
  -n|--name      -- For conda, sets the environment name (default: '${CONDA_DEFAULTNAME}').
                    For docker, sets the image tag (default: '${DOCKER_DEFAULTNAME}').
                    For singularity, sets the output image filename (default: './${SINGULARITY_DEFAULTNAME}').
  -c|--conda-prefix -- If set, use this as the location to store the built conda
                       environment instead of setting a name and using the default
                       prefix.

Flags:
  --debug        -- Increased verbosity for developer use.
  -h|--help      -- Show this message and exit.

If you encounter any issues with this script, please contact the authors at:
- ${MAINTAINER}
- GitHub issues: ${ISSUES_URL}
"
}


check_nodefault_param() {
    FLAG="${1}"
    PARAM="${2}"
    VALUE="${3}"
    [ ! -z "${PARAM:-}" ] && (echo "Argument ${FLAG} supplied multiple times" 1>&2; exit 1)
    [ -z "${VALUE:-}" ] && (echo "Argument ${FLAG} requires a value" 1>&2; exit 1)
    true
}

check_param() {
    FLAG="${1}"
    VALUE="${2}"
    [ -z "${VALUE:-}" ] && (echo "Argument ${FLAG} requires a value" 1>&2; exit 1)
    true
}



while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--help)
    usage
    help
    exit 0
    ;;
    -3|--signalp3)
    check_param "-3|--signalp3" "${2:-}"
    SIGNALP3="$2"
    shift # past argument
    shift # past value
    ;;
    -4|--signalp4)
    check_param "-4|--signalp4" "${2:-}"
    SIGNALP4="$2"
    shift # past argument
    shift # past value
    ;;
    -5|--signalp5)
    check_param "-5|--signalp5" "${2:-}"
    SIGNALP5="$2"
    shift # past argument
    shift # past value
    ;;
    -t|--targetp2)
    check_param "-t|--targetp2" "${2:-}"
    TARGETP2="$2"
    shift # past argument
    shift # past value
    ;;
    -d|--deeploc)
    check_param "-d|--deeploc" "${2:-}"
    DEEPLOC="$2"
    shift # past argument
    shift # past value
    ;;
    -m|--tmhmm)
    check_param "-m|--tmhmm" "${2:-}"
    TMHMM="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--phobius)
    check_param "-p|--phobius" "${2:-}"
    PHOBIUS="$2"
    shift # past argument
    shift # past value
    ;;
    -v|--version)
    check_param "-v|--version" "${2:-}"
    VERSION="$2"
    shift # past argument
    shift # past value
    ;;
    -n|--name)
    check_nodefault_param "-n|--name" "${NAME:-}" "${2:-}"
    NAME="$2"
    shift # past argument
    shift # past value
    ;;
    -c|--conda-prefix)
    check_nodefault_param "-c|--conda-prefix" "${NAME:-}" "${2:-}"
    CONDA_ENV_DIR="$2"
    shift # past argument
    shift # past value
    ;;
    --debug)
    DEBUG=true
    shift # past argument
    ;;
    conda|docker|singularity)    # required positional subcommand
    if [ ! -z "${ENVIRONMENT:-}" ]
    then
        echo "You specified to setup both '${ENVIRONMENT}' and '${1}'." 1>&2
        echo "We can only setup one at a time." 1>&2
        exit 1
    fi
    ENVIRONMENT="$1"
    shift # past argument
    ;;
    *)    # unknown option
    echo "ERROR: Encountered an unknown parameter '${1:-}'." 1>&2
    usage_err
    exit 1
    ;;
esac
done

if [ "${DEBUG:-}" = "true" ]
then
    set -x
fi

### CHECK USER ARGUMENTS

FAILED=false
[ -z "${SIGNALP3:-}" ] && echo "Please provide the source for signalp3." 1>&2 && FAILED=true
[ -z "${SIGNALP4:-}" ] && echo "Please provide the source for signalp4." 1>&2 && FAILED=true
[ -z "${SIGNALP5:-}" ] && echo "Please provide the source for signalp5." 1>&2 && FAILED=true
[ -z "${TARGETP2:-}" ] && echo "Please provide the source for targetp2." 1>&2 && FAILED=true
[ -z "${DEEPLOC:-}" ] && echo "Please provide the source for deeploc." 1>&2 && FAILED=true
[ -z "${TMHMM:-}" ] && echo "Please provide the source for tmhmm." 1>&2 && FAILED=true
[ -z "${PHOBIUS:-}" ] && echo "Please provide the source for phobius." 1>&2 && FAILED=true

[ -z "${ENVIRONMENT}" ] && (echo "Please tell us which environment you'd like to install: conda, docker or singularity." 1>&2; FAILED=true)

if [ "${FAILED}" = true ]
then
    echo
    usage_err
    exit 1;
fi


### CHECK THAT THE TARBALLS EXIST
[ ! -f "${SIGNALP3:-}" ] && echo "The specified archive for signalp3 '${SIGNALP3}' does not exist." 1>&2 && FAILED=true
[ ! -f "${SIGNALP4:-}" ] && echo "The specified archive for signalp4 '${SIGNALP4}' does not exist." 1>&2 && FAILED=true
[ ! -f "${SIGNALP5:-}" ] && echo "The specified archive for signalp5 '${SIGNALP5}' does not exist." 1>&2 && FAILED=true
[ ! -f "${TARGETP2:-}" ] && echo "The specified archive for targetp2 '${TARGETP2}' does not exist." 1>&2 && FAILED=true
[ ! -f "${DEEPLOC:-}" ] && echo "The specified archive for deeploc '${DEEPLOC}' does not exist." 1>&2 && FAILED=true
[ ! -f "${TMHMM:-}" ] && echo "The specified archive for tmhmm '${TMHMM}' does not exist." 1>&2 && FAILED=true
[ ! -f "${PHOBIUS:-}" ] && echo "The specified archive for phobius '${PHOBIUS}' does not exist." 1>&2 && FAILED=true

if [ "${FAILED}" = "true" ]
then
    echo 1>&2
    echo "Please check that the filename you've provided are correct." 1>&2
    echo "Note that the archive must be in it's compressed form rather than as an uncompressed directory." 1>&2

    exit 1;
fi


### ERROR MESSAGES

proprietary_install_error() {
    echo 1>&2
    echo "ERROR: One or more of the proprietary package registrations failed." 1>&2
    echo "Please read the error message above, and re-run this script if you can resolve it." 1>&2
}

conda_env_create_error() {
    echo "ERROR: creating the conda environment failed" 1>&2
    echo "Usually this happens if you already have an environment with the name or path prefix that we tried to use." 1>&2
    echo "You can change the name we use with the '-n' flag, or the path prefix with the '-c' flag." 1>&2
    echo "Otherwise you can remove the old environment with:" 1>&2
    echo "  conda env remove --name ${NAME:-envname}" 1>&2
    echo "  conda env remove --prefix ${CONDA_ENV_DIR:-path/to/your/env}" 1>&2
    echo 1>&2
    echo "Please rerun this script when you have fixed this" 1>&2
}

singularity_build_error() {
    echo 1>&2
    echo "ERROR: creating the singularity image failed" 1>&2
    echo "Please read any generated errors above to see if you can resolve it." 1>&2
}

docker_build_error() {
    echo 1>&2
    echo "ERROR: creating the docker image failed" 1>&2
    echo "Please read any generated errors above to see if you can resolve it." 1>&2
}

contact_fix_issue() {
    # TODO add docs url to this message
    echo "Please look at our documentation and advanced install guide for tips." 1>&2
    echo "If you are unable to resolve the issue please contact the authors or create an issue on github." 1>&2
    echo "We'll do our best to help you, and make updates to resolve or document the issue." 1>&2
    echo 1>&2
    echo "Maintainer: ${MAINTAINER}" 1>&2
    echo "GitHub Issues: ${ISSUES_URL}" 1>&2
}


check_docker_installed() {
    if ! which docker > /dev/null
    then
        echo "ERROR: Docker doesn't seem to be installed and available on your PATH." 1>&2
        echo "Please install docker for your operating system as described here:" 1>&2
        echo "- https://docs.docker.com/engine/install/" 1>&2
        exit 1;
    fi
}


check_singularity_installed() {
    if ! which singularity > /dev/null
    then
        echo "ERROR: singularity doesn't seem to be installed and available on your PATH." 1>&2
        echo "Please install the latest singularity v3+ as described in the user guides:" 1>&2
        echo "- https://sylabs.io/docs/" 1>&2
        exit 1;
    fi
}


check_conda_installed() {
    if ! which conda > /dev/null
    then
        echo "ERROR: Conda doesn't seem to be installed and available on your PATH." 1>&2
        echo "Please install Miniconda (or anaconda) and follow their instructions." 1>&2
        echo "- https://docs.conda.io/en/latest/miniconda.html#linux-installers" 1>&2
        echo "- https://docs.conda.io/projects/conda/en/latest/user-guide/install/linux.html" 1>&2
        exit 1;
    fi
}


get_env_path() {
    NAME="$1"

    # Basically we pick out the last column where the first column matches the
    # environment name.
    # The lines are of one of the following forms (excluding comment lines):
    #   envname1        /path/to/envs/envname1
    #   envname2     *  /path/to/envs/envname2
    #                   /path/to/custom/path/env
    # The * indicates the current environment, so we have to select the last
    # column instead of column 2 or 3

    # Distros should have at least one of the following tools.
    if which awk > /dev/null 2>&1
    then
        conda info -e | awk -v name="${NAME}" '$1 == name {print $NF}' | head -n 1
    elif which sed > /dev/null 2>&1
    then
        conda info -e | sed -n "/^${NAME}[[:space:]]/s/[^[:space:]]*[[:space:]]*\**[[:space:]]*\([^[:space:]]\)/\\1/p" | head -n1
    elif which python3 > /dev/null 2>&1
    then
        conda info -e \
        | python3 -c "
import sys
lines = sys.stdin.readlines()
filtered = (k.strip() for k in lines if not (k.startswith('#') or k.strip() == ''))
extra_filtered = (k for k in filtered if k.split()[0] == '${NAME}')
e = [k.split()[-1] for k in extra_filtered]
e.append('') # Avoid an error here
print(e[0].strip())
        "
    fi
}


check_is_linux() {
    OS=$(uname)
    if [ "${OS^^}" != "LINUX" ]
    then
        echo "ERROR: We can only support conda on linux due to some dependency requirements." 1>&2
        echo "If you are running Mac or Windows, we suggest you use a virtual machine, or use the docker or singularity containerised dependencies." 1>&2
        exit 1;
    fi
}


get_abs_filename() {
  # $1 : relative filename
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}


setup_conda() {
    URL="${REPOBASE}/${VERSION}/environment.yml"
    NAME="${NAME:-${CONDA_DEFAULTNAME}}"

    check_conda_installed
    check_is_linux

    echo "## Setting up conda environment."
    echo

    TMPFILE=".predector$$.yml"
    curl -o "${TMPFILE}" -s "${URL}"

    # This is to allow non-standard environment paths
    if [ -z "${CONDA_ENV_DIR:-}" ]
    then
        conda env create --name "${NAME}" --file "${TMPFILE}" || RETCODE="$?"
    else
        conda env create --prefix "${CONDA_ENV_DIR}" --file "${TMPFILE}" || RETCODE="$?"
    fi

    rm -f "${TMPFILE}"

    if [ "${RETCODE:-0}" -ne 0 ]
    then
        conda_env_create_error
        contact_fix_issue
        exit "${RETCODE}";
    fi

    set +u
    eval "$(conda shell.bash hook)"

    if [ -z "${CONDA_ENV_DIR:-}" ]
    then
        conda activate "${NAME}"
    else
        conda activate "${CONDA_ENV_DIR}"
    fi

    set -u


    echo
    echo "## Finished creating the base environment"
    echo "Registering the proprietary software."
    echo

    signalp3-register "${SIGNALP3}" && echo \
    && signalp4-register "${SIGNALP4}" && echo \
    && signalp5-register "${SIGNALP5}" && echo \
    && targetp2-register "${TARGETP2}" && echo \
    && deeploc-register "${DEEPLOC}" && echo \
    && phobius-register "${PHOBIUS}" && echo \
    && tmhmm2-register "${TMHMM}" && echo \
    || RETCODE="$?"

    if [ "${RETCODE:-0}" -ne 0 ]
    then
        proprietary_install_error
        contact_fix_issue
        exit "${RETCODE:-0}";
    fi


    echo "The predector conda environment has been successfully installed."

    if [ -z "${CONDA_ENV_DIR:-}" ]
    then
        CONDA_PREFIX="$(get_env_path "${NAME}")"
    else
        CONDA_PREFIX="$(get_abs_filename "${CONDA_ENV_DIR}")"
    fi

    if [ ! -z "${CONDA_PREFIX:-}" ]
    then
        echo "When you run the pipeline, please supply the parameter:"
        echo "  '-with-conda \"${CONDA_PREFIX}\"'"
    fi
}


check_docker_needs_sudo() {
    MSG=$(docker images 2>&1) || RETCODE="$?"

    if [ "${RETCODE:-0}" -ne "0" ]
    then
        if grep '^Got permission denied' <(echo "${MSG}") > /dev/null 2>&1
        then
            echo "true"
        else
            echo 1>&2
            echo "Got unexpected error while testing your docker install with 'docker images'." 1>&2
            echo "${MSG}" 1>&2
            echo 1>&2
            echo "Please try to resolve this issue and try running the script again." 1>&2
            exit "${RETCODE}";
        fi
    else
        echo "false"
    fi
}


setup_docker() {
    URL="${REPOBASE}/${VERSION}/Dockerfile"
    NAME="${NAME:-${DOCKER_DEFAULTNAME}}"

    check_docker_installed

    echo "## Setting up docker image."
    echo

    # This will still fail if non-zero exit not related to permission.
    NEED_SUDO=$(check_docker_needs_sudo)

    if [ "${NEED_SUDO}" = "true" ]
    then
        echo "Your docker installation appears to require root permission."
        echo "Please provide your root password for sudo when prompted."
        echo
        SUDO="sudo"
    else
        SUDO=""
    fi

    curl -s "${URL}" \
    | ${SUDO} docker build \
      --build-arg SIGNALP3="${SIGNALP3}" \
      --build-arg SIGNALP4="${SIGNALP4}" \
      --build-arg SIGNALP5="${SIGNALP5}" \
      --build-arg TARGETP2="${TARGETP2}" \
      --build-arg PHOBIUS="${PHOBIUS}" \
      --build-arg TMHMM="${TMHMM}" \
      --build-arg DEEPLOC="${DEEPLOC}" \
      --tag "${NAME}" \
      --file - \
      . \
    || RETCODE="$?"

    if [ "${RETCODE:-0}" -ne 0 ]
    then
        docker_build_error
        contact_fix_issue
        exit "${RETCODE:-0}";
    fi

    echo
    echo "The predector docker image has been successfully built."
    echo "It should show in 'docker images' as '${NAME}'."
    echo

    if [ "${NEED_SUDO}" = "true" ]
    then
        SUDO_MSG="Your docker installation seems to require sudo to run."
    else
        SUDO_MSG=""
    fi

    if [ "${NAME}" = "${DOCKER_DEFAULTNAME}" ]
    then
        echo "When you run the pipeline, please use one of the following profiles:"
        echo "  '-profile docker'"
        echo "  '-profile docker_sudo'"
        echo
        if [ "${NEED_SUDO}" = "true" ]
        then
            echo "Your installation seems to require sudo to run."
            echo "Please use the 'docker_sudo' profile if you're running on this computer."
        else
            echo "Your installation doesn't seem to require sudo to run."
            echo "Please use the 'docker' profile if you're running on this computer."
        fi
    else
        echo "When you run the pipeline, please use the parameter:"
        echo "  '-with-docker \"${NAME}\"'"
        echo

        if [ "${NEED_SUDO}" = "true" ]
        then
            echo "Your installation seems to require sudo to run."
            echo "Please also use the 'docker_sudo' profile if you're running on this computer."
            echo "  '-profile docker_sudo'"
            else
            echo "If you're running on a different computer that requires sudo for docker,"
            echo "please also use the 'docker_sudo' profile."
            echo "  '-profile docker_sudo'"
        fi
    fi
}


setup_singularity() {
    URL="${REPOBASE}/${VERSION}/singularity.def"
    NAME="${NAME:-${SINGULARITY_DEFAULTNAME}}"
    check_singularity_installed

    echo "## Setting up singularity image."
    echo

    # This is used to emulate the --build-args functionality of docker.
    # Singularity lacks this feature. You can unset the variables after you're done.
    export SIGNALP3="${SIGNALP3}"
    export SIGNALP4="${SIGNALP4}"
    export SIGNALP5="${SIGNALP5}"
    export TARGETP2="${TARGETP2}"
    export PHOBIUS="${PHOBIUS}"
    export TMHMM="${TMHMM}"
    export DEEPLOC="${DEEPLOC}"

    # We set this so that the /tmp doesn't fill up.
    export SINGULARITY_CACHEDIR="${PWD}/.cache$$"
    export SINGULARITY_TMPDIR="${SINGULARITY_CACHEDIR}"
    export SINGULARITY_LOCALCACHEDIR="${SINGULARITY_CACHEDIR}"
    mkdir -p "${SINGULARITY_CACHEDIR}"

    # Set the output container filename with the default if user didn't specify.
    export NAME

    # Download the .def file
    export TMPFILE=".predector$$.def"
    curl -s -o "${TMPFILE}" "${URL}"

    # Build the .sif singularity image.
    # Note that `sudo -E` is important, it tells sudo to keep the environment variables
    # that we just set.
    sudo -E bash -eu -c '
        singularity build "${NAME}" "${TMPFILE}" || RETCODE="$?"
        rm -rf -- "${SINGULARITY_CACHEDIR}"
        exit "${RETCODE:-0}"
    ' || RETCODE="$?"

    rm -f "${TMPFILE}"

    if [ "${RETCODE:-0}" -ne 0 ]
    then
        singularity_build_error
        contact_fix_issue
        exit "${RETCODE}";
    fi

    echo "The predector singularity image has been successfully built."
    echo "When you run the pipeline, please supply the parameter:"
    echo "  '-with-singularity \"${NAME}\"'"
}


if [ "${ENVIRONMENT}" = "conda" ]
then
    setup_conda
elif [ "${ENVIRONMENT}" = "docker" ]
then
    setup_docker
elif [ "${ENVIRONMENT}" = "singularity" ]
then
    setup_singularity
else
    echo "We somehow are trying to setup an environment other than conda, docker or singularity." 1>&2
    echo "Please contact the authors to report this issue." 1>&2
    exit 1;
fi
