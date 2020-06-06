#!/usr/bin/env bash

FASTA="$1"
NCPU="$2"
MAX_CHUNK="$3"

NSEQS=$(grep -c '^>' "$1" || echo "0")

rounded_up () {
    echo $(( ($1 - 1) / $2 + 1 ))
}

min () {
    [ "$1" -ge "$2" ] && echo "$2" || echo "$1"
}

ROUNDED="$(rounded_up "${NSEQS}" "${NCPU}")"
min "${ROUNDED}" "${MAX_CHUNK}"
