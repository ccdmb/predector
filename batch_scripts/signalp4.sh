#!/usr/bin/env bash

set -euo pipefail

ANALYSIS="signalp4"
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
TMP="tmpdir_sp4_${HOSTNAME:-}_$$"
mkdir "${TMP}"
cd "${TMP}"

signalp4 -t "euk" -f short "${FASTA}" \
| predutils r2js \
    --pipeline-version "${PIPELINE_VERSION}" \
    --software-version "${SOFTWARE_VERSION}" \
    ${DB_VERSION_STR} \
    "${ANALYSIS}" - "${FASTA}"

cd "${ORIGDIR}"
rm -rf -- "${TMP}"
