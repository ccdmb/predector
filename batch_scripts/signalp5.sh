#!/usr/bin/env bash

set -euo pipefail

ANALYSIS="signalp5"
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

OUT="tmp\$\$"
signalp5 \
    -org euk \
    -format short \
    -tmp "${TMPDIR}" \
    -fasta "${fasta}" \
    -prefix "${OUT}" \
    1>&2

predutils r2js \
    --pipeline-version "${PIPELINE_VERSION}" \
    --software-version "${SOFTWARE_VERSION}" \
    ${DB_VERSION_STR} \
    "${ANALYSIS}" ${OUT}_summary.signalp5 "${FASTA}"

rm -rf -- "${OUT}"* "${TMPDIR}"
