# In here you should remove any (and only the) files that you installed in the register.sh script.
# Note that we will automatically replace the placeholder script.

# Make sure you use the -f variants to avoid errors if a file doesn't exist.

rm -f "${TARGET_DIR}/"{signalp,signalp.1,signalp-3.0.readme,syn-3.0}
rm -rf -- "${TARGET_DIR}/test"
rm -rf -- "${TARGET_DIR}/tmp"
rm -rf -- "${TARGET_DIR}/"{syn-2.0,syn-1.1,syn-1.0,syn}
rm -rf -- "${TARGET_DIR}/mod"
rm -rf -- "${TARGET_DIR}/how"
rm -rf -- "${TARGET_DIR}/hmm"
rm -rf -- "${TARGET_DIR}/bin"
