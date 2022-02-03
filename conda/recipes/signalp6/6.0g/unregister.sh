# In here you should remove any (and only the) files that you installed in the register.sh script.
# Note that we will automatically replace the placeholder script.

# Make sure you use the -f variants to avoid errors if a file doesn't exist.

SIGNALP_DIR="$(python3 -c "import signalp; import os; print(os.path.dirname(signalp.__file__))" 2> /dev/null || :)"


python3 -m pip uninstall -y signalp6

# If we copied the model files in after pip, we need
# to delete them manually
if [ ! -z "${SIGNALP_DIR:-}" ]
then
    rm -rf -- "${SIGNALP_DIR}"
fi

# If we copied the model files in after pip, we need
# to delete them manually
