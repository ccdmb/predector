#!/usr/bin/env bash

set -eux

INCLUDE_PATH="${PREFIX}/include"
LIBRARY_PATH="${PREFIX}/lib"

make HAVE_MPI=1
make test
make install INSTALL_DIR="${PREFIX}"
install src/ffindex_apply_mpi "${PREFIX}/bin/ffindex_apply_mpi"