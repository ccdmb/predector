#!/usr/bin/env bash

TARGET_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

rm -rf -- "${TARGET_DIR}/lib"
rm -f "${TARGET_DIR}"/bin/*
rm "${TARGET_DIR}/"{README,TMHMM2.0.html}

mv "${TARGET_DIR}/tmhmm-placeholder.sh" "${TARGET_DIR}/bin/tmhmm"
mv "${TARGET_DIR}/tmhmmformat-placeholder.sh" "${TARGET_DIR}/bin/tmhmmformat.pl"
