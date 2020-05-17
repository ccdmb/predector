#!/usr/bin/env bash

set -eux

PKG_NAME_UPPER="${PKG_NAME^^}"
PKG_VERSION_NODOT="${PKG_VERSION//./_}"

EFFECTORP_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

mkdir -p "${EFFECTORP_DIR}"
mkdir -p "${PREFIX}/bin"

cp -r \
    COPYING README \
    WekaManual.pdf \
    data doc \
    documentation.css documentation.html \
    remoteExperimentServer.jar weka.gif \
    weka.ico weka.jar "${WEKA_DIR}"

WEKA_DIR_ENV="${PKG_NAME_UPPER}_${PKG_VERSION_NODOT}_DIR"
WEKA_JAR_ENV="${PKG_NAME_UPPER}_${PKG_VERSION_NODOT}_JAR"
echo "export ${WEKA_DIR_ENV}=\"\${CONDA_PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}\"" > activate.sh
echo "export ${WEKA_JAR_ENV}=\"\${${WEKA_DIR_ENV}}/weka.jar\"" >> activate.sh
echo "unset ${WEKA_DIR_ENV}" > deactivate.sh
echo "unset ${WEKA_JAR_ENV}" >> deactivate.sh

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    mv "${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${PKG_VERSION_NODOT}_${CHANGE}.sh"
done