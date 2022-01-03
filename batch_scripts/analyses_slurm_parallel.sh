#!/usr/bin/env bash
set -euo pipefail

export BASENAME=$(dirname ${0})

# Set some defaults

CONTAINER="${PWD}/predector.sif"
ANALYSIS=
PIPELINE_VERSION="1.2.4-alpha"
SOFTWARE_VERSION=
DATABASE_VERSION=
FASTA=
CHUNK_SIZE=
PARTITION="workq"
ACCOUNT=y95
TIME=1-00:00:00
PREFIX=

NODES=1
NTASKS_PER_NODE=24
CPUS_PER_NODE=24

SCRIPT=

DEBUG=false

# signalp3_hmm signalp3_nn signalp4 signalp5 signalp6 deepsig phobius tmhmm targetp_non_plant deeploc apoplastp localizer effectorp1 effectorp2 effectorp3 deepredeff_fungi deepredeff_oomycete kex2_cutsite rxlr_like_motif pepstats pfamscan dbcan effectordb phibase


analysis_to_scriptname() {
    echo "${BASENAME}/${1}.sh"
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


usage() {
    echo -e "USAGE:"
}


while [[ $# -gt 0 ]]
do
key="${1}"

case ${key} in
    -h|--help)
    usage
    exit 0
    ;;
    -s|--software-version)
    check_param "-s|--software-version" "${2:-}"
    SOFTWARE_VERSION="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--pipeline-verison)
    check_param "-p|--pipeline-version" "${2:-}"
    PIPELINE_VERSION="$2"
    shift # past argument
    shift # past value
    ;;
    -d|--database-version)
    check_param "-d|--database-version" "${2:-}"
    DATABASE_VERSION="$2"
    shift # past argument
    shift # past value
    ;;
    -i|--fasta)
    check_nodefault_param "-i|--fasta" "${FASTA:-}" "${2:-}"
    FASTA="$2"
    shift # past argument
    shift # past value
    ;;
    --chunk-size)
    check_param "--chunk-size" "${2:-}"
    CHUNK_SIZE="${2}"
    shift
    shift
    ;;
    --nodes)
    check_param "--nodes" "${2:-}"
    NODES="${2}"
    shift
    shift
    ;;
    --ntasks-per-node)
    check_param "--ntasks-per-node" "${2:-}"
    NTASKS_PER_NODE="${2}"
    shift
    shift
    ;;
    --cpus-per-node)
    check_param "--cpus-per-node" "${2:-}"
    CPUS_PER_NODE="${2}"
    shift
    shift
    ;;
    --partition)
    check_param "--partition" "${2:-}"
    PARTITION="${2}"
    shift
    shift
    ;;
    --account)
    check_param "--account" "${2:-}"
    ACCOUNT="${2}"
    shift
    shift
    ;;
    --time)
    check_param "--time" "${2:-}"
    TIME="${2}"
    shift
    shift
    ;;
    --container)
    check_param "--container" "${2:-}"
    CONTAINER="${2}"
    shift
    shift
    ;;
    --prefix)
    check_param "--prefix" "${2:-}"
    PREFIX="${2}"
    shift
    shift
    ;;
    --debug)
    DEBUG=true
    shift # past argument
    ;;
    signalp3_hmm|signalp3_nn|signalp4|signalp5|signalp6|deepsig|phobius|tmhmm|targetp_non_plant|deeploc|apoplastp|localizer|effectorp1|effectorp2|effectorp3|deepredeff_fungi|deepredeff_oomycete|kex2_cutsite|rxlr_like_motif|pepstats|pfamscan|dbcan|effectordb|phibase)  # Required positional argument
    if [ ! -z "${ANALYSIS:-}" ]
    then
        echo "You specified both '${ANALYSIS}' and '${1}' analyses." 1>&2
        exit 1
    fi
    ANALYSIS="$1"
    shift # past argument
    ;;
    *)    # unknown option
    echo "ERROR: Encountered an unknown parameter '${1:-}'." 1>&2
    usage
    exit 1
    ;;
esac
done

if [ "${DEBUG:-}" = "true" ]
then
    set -x
fi


[ -z ${CHUNK_SIZE:-} ] && CHUNK_SIZE=100

# Set some default parameters based on pipeline version
case ${ANALYSIS} in
    signalp3_hmm)
        SOFTWARE_VERSION=${SOFTWARE_VERSION:-3.0b}
        DATABASE_VERSION=
        ;;
    signalp3_nn)
        SOFTWARE_VERSION=${SOFTWARE_VERSION:-3.0b}
        DATABASE_VERSION=
        ;;
    signalp4)
        SOFTWARE_VERSION=${SOFTWARE_VERSION:-4.1g}
        DATABASE_VERSION=
        ;;
    signalp5)
        SOFTWARE_VERSION=${SOFTWARE_VERSION:-5.0b}
        DATABASE_VERSION=
        CHUNK_SIZE=${CHUNK_SIZE:-1000}
        NTASKS_PER_NODE=1
        ;;
    signalp6)
        SOFTWARE_VERSION=${SOFTWARE_VERSION:-6.0d}
        DATABASE_VERSION=
        CHUNK_SIZE=${CHUNK_SIZE:-1000}
        NTASKS_PER_NODE=1
        ;;
    deepsig)
        SOFTWARE_VERSION=${SOFTWARE_VERSION:-0f1e1d9}
        DATABASE_VERSION=
        CHUNK_SIZE=${CHUNK_SIZE:-1000}
        ;;
    phobius)
        SOFTWARE_VERSION=${SOFTWARE_VERSION:-1.01}
        DATABASE_VERSION=
        ;;
    tmhmm)
        SOFTWARE_VERSION=${SOFTWARE_VERSION:-2.0c}
        DATABASE_VERSION=
        ;;
    targetp_non_plant)
        SOFTWARE_VERSION=${SOFTWARE_VERSION:-2.0}
        DATABASE_VERSION=
        CHUNK_SIZE=${CHUNK_SIZE:-1000}
        NTASKS_PER_NODE=1
        ;;
    deeploc)
        SOFTWARE_VERSION=${SOFTWARE_VERSION:-1.0}
        DATABASE_VERSION=
        CHUNK_SIZE=${CHUNK_SIZE:-1000}
        ;;
    apoplastp)
        SOFTWARE_VERSION=${SOFTWARE_VERSION:-1.0}
        DATABASE_VERSION=
        ;;
    localizer)
        SOFTWARE_VERSION=${SOFTWARE_VERSION:-1.0.3}
        DATABASE_VERSION=
        ;;
    effectorp1)
        SOFTWARE_VERSION=${SOFTWARE_VERSION:-1.0}
        DATABASE_VERSION=
        ;;
    effectorp2)
        SOFTWARE_VERSION=${SOFTWARE_VERSION:-2.0}
        DATABASE_VERSION=
        ;;
    effectorp3)
        SOFTWARE_VERSION=${SOFTWARE_VERSION:-3.0}
        DATABASE_VERSION=
        ;;
    deepredeff_fungi)
        SOFTWARE_VERSION=${SOFTWARE_VERSION:-0.1.1}
        DATABASE_VERSION=
        CHUNK_SIZE=${CHUNK_SIZE:-1000}
        NTASKS_PER_NODE=1
        ;;
    deepredeff_oomycete)
        SOFTWARE_VERSION=${SOFTWARE_VERSION:-0.1.1}
        DATABASE_VERSION=
        CHUNK_SIZE=${CHUNK_SIZE:-1000}
        NTASKS_PER_NODE=1
        ;;
    kex2_cutsite)
        SOFTWARE_VERSION=${SOFTWARE_VERSION:-0.8.0}
        DATABASE_VERSION=
        CHUNK_SIZE=${CHUNK_SIZE:-1000}
        ;;
    rxlr_like_motif)
        SOFTWARE_VERSION=${SOFTWARE_VERSION:-0.8.0}
        DATABASE_VERSION=
        CHUNK_SIZE=${CHUNK_SIZE:-1000}
        ;;
    pepstats)
        SOFTWARE_VERSION=${SOFTWARE_VERSION:-6.6.0.0}
        DATABASE_VERSION=
        CHUNK_SIZE=${CHUNK_SIZE:-10000}
        ;;
    pfamscan)
        SOFTWARE_VERSION=${SOFTWARE_VERSION:-1.6-3.3.2}
        DATABASE_VERSION=${DATABASE_VERSION:-35.0}
        ;;
    dbcan)
        SOFTWARE_VERSION=${SOFTWARE_VERSION:-3.3.2}
        DATABASE_VERSION=${DATABASE_VERSION:-V10}
        ;;
    effectordb)
        SOFTWARE_VERSION=${SOFTWARE_VERSION:-3.3.2}
        DATABASE_VERSION=${DATABASE_VERSION:-1}
        ;;
    phibase)
        SOFTWARE_VERSION=${SOFTWARE_VERSION:-13.45111}
        DATABASE_VERSION=${DATABASE_VERSION:-v4-12}
        CHUNK_SIZE=${CHUNK_SIZE:-5000}
        NTASKS_PER_NODE=1
        ;;
    *)  # Unknown option
    echo "ERROR: Unknown analysis specified '${ANALYSIS}'." 1>&2
    exit 1
    ;;
esac

FAILED=false

[ -z "${ANALYSIS:-}" ] && echo "Please specify which analysis to run." 1>&2 && FAILED=true
[ -z "${FASTA:-}" ] && echo "Please specify which fasta file to use." 1>&2 && FAILED=true

if [ "${FAILED}" = true ]
then
    echo
    usage
    exit 1;
fi

SCRIPT="$(analysis_to_scriptname ${ANALYSIS:-})"
[ ! -f "${SCRIPT:-}" ] && echo "The script for analysis ${ANALYSIS:-} doesn't exist" && FAILED=true

if [ "${FAILED}" = true ]
then
    echo
    usage
    exit 1;
fi

[ -z "${PREFIX:-}" ] && PREFIX="${ANALYSIS}_$(basename ${FASTA})"

CPUS_PER_TASK=$(( ${CPUS_PER_NODE:-1} / ${NTASKS_PER_NODE:-1} ))
NTASKS=$(( ${NODES} * ${NTASKS_PER_NODE} ))

SRUN="srun --export=ALL --exact --exclusive -N \${SLURM_NODES} -n \${SLURM_NTASKS} --cpus-per-task ${CPUS_PER_TASK}"
PARALLEL="parallel --halt now,fail=1 --delay 0.5 -j \${SLURM_NTASKS} --joblog '${PREFIX}.log' --resume --line-buffer --recstart '>' -N "${CHUNK_SIZE}" --cat"

#sbatch \
#    --nodes="${NODES}" \
#    --ntasks-per-node="${NTASKS_PER_NODE}" \
#    --time="${TIME}" \
#    --account=${ACCOUNT} \
#    --partition="${PARTITION}" \
#    --export=NONE \
cat    <<EOF > test.txt
#!/bin/bash -l

module load parallel
module load singularity

set -euo pipefail

export OMP_NUM_THREADS="${CPUS_PER_TASK}"
${PARALLEL} "${SRUN} singularity exec ${CONTAINER} ${SCRIPT} ${PIPELINE_VERSION} ${SOFTWARE_VERSION} ${DATABASE_VERSION} {}" < "${FASTA}" | cat >> "${PREFIX}.jsonl"
EOF
