#!/usr/bin/env bash

set -eu

TMPDIR="lcl_$$"
INFILE="input_$$.fasta"
cat /dev/stdin > "${INFILE}"

LOCALIZER.py -e -M -i "${INFILE}" -o "${TMPDIR}"

cat "${TMPDIR}/Results.txt"
rm -rf -- "${TMPDIR}"
