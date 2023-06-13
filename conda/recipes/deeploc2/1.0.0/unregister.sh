# In here you should remove any (and only the) files that you installed in the register.sh script.
# Note that we will automatically replace the placeholder script.


# If the source folder isn't empty and pip3 is installed
if [ python3 -m pip > /dev/null 2>&1 ]
then
    python3 -m pip uninstall --yes DeepLoc
fi

rm -rf -- "${TARGET_DIR}/src"
