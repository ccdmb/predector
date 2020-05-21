#!/usr/bin/env bash

TARGET_DIR="${PREFIX}/share/${PKG_NAME}-${PKG_VERSION}-${PKG_BUILDNUM}"

rm -f "${TARGET_DIR}/"{decodeanhmm,decodeanhmm.64bit}
rm -f "${TARGET_DIR}/"{README,LicenseAgreement.txt,OPSD_SHEEP,Q8TCT8}
rm -f "${TARGET_DIR}/"{phobius.model,phobius.options,phobius.pl}

mv "${TARGET_DIR}/phobius-placeholder.sh" "${TARGET_DIR}/phobius.pl"
