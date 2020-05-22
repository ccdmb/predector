# In here you should remove any (and only the) files that you installed in the register.sh script.
# Note that we will automatically replace the placeholder script.

# Make sure you use the -f variants to avoid errors if a file doesn't exist.

# An example is here for the signalp 5 recipe
rm -f "${TARGET_DIR}/"{signalp-5.0b.readme,signalp.1}
rm -rf -- "${TARGET_DIR}/test"
rm -rf -- "${TARGET_DIR}/lib"

rm -f "${TARGET_DIR}/bin/signalp"
