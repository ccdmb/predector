#!/usr/bin/env bash

set -euo pipefail

ANALYSIS="dbcan"
FASTA="${1}"
PIPELINE_VERSION="${2}"
SOFTWARE_VERSION="${3}"
DATABASE_VERSION="${4-}"

if [ -z "${DATABASE_VERSION:-}" ]
then
    DB_VERSION_STR=""
else
    DB_VERSION_STR="--database-version '${DATABASE_VERSION}'"
fi

TMPFILE="tmp$$"
hmmscan \
    --domtblout "${TMPFILE}" \
    dbcan/dbcan.hmm \
    "${FASTA}" \
    > /dev/null

predutils r2js \
    --pipeline-version "${PIPELINE_VERSION}" \
    --software-version "${SOFTWARE_VERSION}" \
    ${DB_VERSION_STR} \
    "${ANALYSIS}" "${TMPFILE}" "${FASTA}"

rm -f "${TMPFILE}"
