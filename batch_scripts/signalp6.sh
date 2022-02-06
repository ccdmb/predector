#!/usr/bin/env bash

set -euo pipefail

ANALYSIS="signalp6"
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

TMPDIR="tmpdir$$"
mkdir "${TMPDIR}"

signalp6 \
    --fastafile "${FASTA}" \
    --output_dir "${TMPDIR}" \
    --format none \
    --organism eukarya \
    --mode fast \
    --bsize 64 \
    1>&2

predutils r2js \
    --pipeline-version "${PIPELINE_VERSION}" \
    --software-version "${SOFTWARE_VERSION}" \
    ${DB_VERSION_STR} \
    "${ANALYSIS}" "${TMPDIR}/prediction_results.txt" "${FASTA}"

rm -rf -- "${OUT}"* "${TMPDIR}"
