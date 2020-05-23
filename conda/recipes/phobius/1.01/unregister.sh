# In here you should remove any (and only the) files that you installed in the register.sh script.
# Note that we will automatically replace the placeholder script.

# Make sure you use the -f variants to avoid errors if a file doesn't exist.

rm -f "${TARGET_DIR}/"{decodeanhmm,decodeanhmm.64bit}
rm -f "${TARGET_DIR}/"{README,LicenseAgreement.txt,OPSD_SHEEP,Q8TCT8}
rm -f "${TARGET_DIR}/"{phobius.model,phobius.options,phobius.pl}
