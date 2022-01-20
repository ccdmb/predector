#!/usr/bin/env bash

set -euo pipefail

export DIRNAME=$(dirname ${0:-})

ANALYSIS="signalp3_nn"
FASTA="${1}"
PIPELINE_VERSION="${2}"
SOFTWARE_VERSION="${3}"
DATABASE_VERSION="${4:-}"

if [ -z "${DATABASE_VERSION:-}" ]
then
    DB_VERSION_STR=""
else
    DB_VERSION_STR="--database-version '${DATABASE_VERSION}'"
fi

ORIGDIR="${PWD}"
TMPDIR="tmp_${ANALYSIS}_${HOSTNAME:-}_$$_${RANDOM}"
mkdir "${TMPDIR}"
cd "${TMPDIR}"

"${DIRNAME}"/../bin/fasta_to_tsv.sh "${FASTA}" \
    | awk -F'\t' '{ s=substr($2, 1, 6000); print $1"\t"s }' \
    | "${DIRNAME}"/../bin/tsv_to_fasta.sh \
    > trunc.fasta

signalp3 -type "euk" -method "nn" -short trunc.fasta \
| predutils r2js \
    --pipeline-version "${PIPELINE_VERSION}" \
    --software-version "${SOFTWARE_VERSION}" \
    ${DB_VERSION_STR} \
    "${ANALYSIS}" - "${FASTA}"

cd "${ORIGDIR}"
rm -rf -- "${TMPDIR}"
