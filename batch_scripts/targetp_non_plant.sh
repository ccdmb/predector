#!/usr/bin/env bash

set -euo pipefail

ANALYSIS="targetp_non_plant"
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

TMPDIR="tmp_${ANALYSIS}_${HOSTNAME:-}_$$_${RANDOM:-}"
mkdir "${TMPDIR}"


ORIGDIR=${PWD}
cd ${TMPDIR}

mkdir tmp
OUT="out"
targetp \
    -fasta "${FASTA}" \
    -org non-pl \
    -format short \
    -tmp ./tmp \
    -prefix "${OUT}" \
    1>&2

predutils r2js \
    --pipeline-version "${PIPELINE_VERSION}" \
    --software-version "${SOFTWARE_VERSION}" \
    ${DB_VERSION_STR} \
    "${ANALYSIS}" "${OUT}_summary.targetp2" "${FASTA}"

cd "${ORIGDIR}"
rm -rf -- "${TMPDIR}"
