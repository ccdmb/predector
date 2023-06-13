#!/usr/bin/env bash

set -euo pipefail

if [ $# -eq 0 ]
then
  INFILE="/dev/stdin"
elif [ "$1" = "-" ]
then
  INFILE="/dev/stdin"
else
  INFILE="${1-:/dev/stdin}"
fi


awk -F '\t' '{ printf(">%s\n%s\n", $1, $2) }' < "${INFILE}"
