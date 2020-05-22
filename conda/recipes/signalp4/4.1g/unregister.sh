# In here you should remove any (and only the) files that you installed in the register.sh script.
# Note that we will automatically replace the placeholder script.

# Make sure you use the -f variants to avoid errors if a file doesn't exist.

rm -f "${TARGET_DIR}/"{signalp,signalp-4.1.readme,signalp.1}
rm -rf -- "${TARGET_DIR}/test"
rm -rf -- "${TARGET_DIR}/syn"
rm -rf -- "${TARGET_DIR}/bin"
rm -rf -- "${TARGET_DIR}/lib"

rm -f "${TARGET_DIR}/bin/signalp"
