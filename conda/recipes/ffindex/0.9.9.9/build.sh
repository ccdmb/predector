#!/usr/bin/env bash

set -eux

INCLUDE_PATH="${PREFIX}/include"
LIBRARY_PATH="${PREFIX}/lib"

# Conda doesn't add lib64 to path.
sed -i '/^libdir=/c libdir=lib' src/Makefile
make HAVE_MPI=1
make test
make install HAVE_MPI=1 INSTALL_DIR="${PREFIX}"

# install src/ffindex_apply_mpi "${PREFIX}/bin/ffindex_apply_mpi"
