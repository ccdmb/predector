#!/usr/bin/env bash

set -euo pipefail

ANALYSIS="effectorp3_fungal"
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

export TMPDIR="tmpdir_${ANALYSIS}_${HOSTNAME:-}_$$_${RANDOM:-}"
mkdir "${TMPDIR}"

TMPFILE="tmp_${ANALYSIS}_${HOSTNAME:-}_$$_${RANDOM:-}"
EffectorP3.py -f -i "${FASTA}" -o "${TMPFILE}" 1>&2

predutils r2js \
    --pipeline-version "${PIPELINE_VERSION}" \
    --software-version "${SOFTWARE_VERSION}" \
    ${DB_VERSION_STR} \
    "${ANALYSIS}" "${TMPFILE}" "${FASTA}"

rm -rf -- "${TMPFILE}" "${TMPDIR}"
