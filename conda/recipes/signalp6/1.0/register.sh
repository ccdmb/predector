# Note: $PKG_* variables are inserted above this line by the build script.
# Note: $ARCHIVE  and TARGET_DIR etc variables are inserted above this line by register-base.

# For most applications this will find the folder that will be extracted from
# the tarball, but some e.g. phobius, will give you weird results.
# Check that this works as expected.
EXTRACTED_DIR_CALLED="signalp6_fast/signalp-6-package"
# "$(basename $(tar -tf "${ARCHIVE}" | head -n 1))"

# Don't change the next 3 lines
mkdir -p "${WORKDIR}"
tar --no-same-owner --directory=${WORKDIR} -xf "${ARCHIVE}"
cd "${WORKDIR}/${EXTRACTED_DIR_CALLED}"


#### Add your code to install here.

python3 -m pip install . -vv --no-deps --compile


# MAKE SURE THAT ALL FILES CAN BE READ BY ANY USER AND
# EXECUTABLES CAN BE RUN BY ANY USER (important for containers)
#cd "${TARGET_DIR}"
#chmod -R a+r .
#chmod a+x bin/*

#nb we delete WORKDIR using a trap command in register-base.sh

# Don't change the next two lines
echo "Finished registering ${PKG_NAME}."
echo "Testing installation..."


# Add a command that uses the test dataset included with the package.
# both TEST_RESULT and TEST_RETCODE should be set.
# If you REALLY have to skip tests, set TEST_RETCODE=0.

# If you get a non-zero exit code, the test will fail.
cd "${WORKDIR}"
EXE=$(which signalp6)
NEW_EXE=${EXE%6}
ln -sf ${EXE} ${NEW_EXE}

TEST_RESULT=$(signalp6 --fastafile "${TARGET_DIR}/test_set.fasta" --format none --mode fast --organism eukarya --output_dir "${WORKDIR}/test")
TEST_RETCODE=$?
