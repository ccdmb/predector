#!/usr/bin/env bash

set -euo pipefail

ANALYSIS="deeploc"
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

TMPDIR="${PWD}/tmpdir_${ANALYSIS}_${HOSTNAME:-}_$$_${RANDOM:-}"
mkdir "${TMPDIR}"

TMPFILE="${PWD}/tmp_${ANALYSIS}_${HOSTNAME:-}_$$_${RANDOM:-}.out"
# The base_compiledir is the important bit here.
# This is where cache-ing happens. But it also creates a lock
# for parallel operations.
export THEANO_FLAGS="device=cpu,floatX=float32,optimizer=fast_compile,cxx=${CXX},base_compiledir=${TMPDIR}"

deeploc -f "${FASTA}" -o "${TMPFILE}" 1>&2

predutils r2js \
    --pipeline-version "${PIPELINE_VERSION}" \
    --software-version "${SOFTWARE_VERSION}" \
    ${DB_VERSION_STR} \
    "${ANALYSIS}" "${TMPFILE}.txt" "${FASTA}"

rm -rf -- "${TMPFILE}"* "${TMPDIR}"
