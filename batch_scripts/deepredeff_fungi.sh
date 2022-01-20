#!/usr/bin/env bash

set -euo pipefail

export DIRNAME=$(dirname ${0:-})

ANALYSIS="deepredeff_fungi"
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

${DIRNAME}/../bin/deepredeff.R -i "${FASTA}" --taxon fungi | tail -n+2 \
| predutils r2js \
    --pipeline-version "${PIPELINE_VERSION}" \
    --software-version "${SOFTWARE_VERSION}" \
    ${DB_VERSION_STR} \
    "${ANALYSIS}" - "${FASTA}"
