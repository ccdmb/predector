#!/usr/bin/env bash

set -euo pipefail

ANALYSIS="dummy"
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

echo STARTED ${HOSTNAME}
timeout 30 sha1sum /dev/zero && :
echo DONE ${HOSTNAME}
