#!/usr/bin/env bash

set -euo pipefail

ANALYSIS="phobius"
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
TMP="tmp_phobius_${HOSTNAME:-phobius}_$$"
mkdir "${TMP}"
cd "${TMP}"

phobius.pl -short "${FASTA}"  \
| tail -n+2 \
| predutils r2js \
    --pipeline-version "${PIPELINE_VERSION}" \
    --software-version "${SOFTWARE_VERSION}" \
    ${DB_VERSION_STR} \
    "${ANALYSIS}" - "${FASTA}"

cd "${ORIGDIR}"
rm -rf -- "${TMP}"
