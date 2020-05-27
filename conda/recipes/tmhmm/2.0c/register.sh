# Note: $PKG_* variables are inserted above this line by the build script.
# Note: $ARCHIVE  and TARGET_DIR etc variables are inserted above this line by register-base.

# For most applications this will find the folder that will be extracted from
# the tarball, but some e.g. phobius, will give you weird results.
# Check that this works as expected.
EXTRACTED_DIR_CALLED="$(basename $(tar -tf "${ARCHIVE}" | head -n 1))"

# Don't change the next 3 lines
mkdir -p "${WORKDIR}"
tar --no-same-owner --directory=${WORKDIR} -xf "${ARCHIVE}"
cd "${WORKDIR}/${EXTRACTED_DIR_CALLED}"


#### Add your code to install here.

mkdir -p "${TARGET_DIR}/bin"

cp bin/* "${TARGET_DIR}/bin"
cp -r lib "${TARGET_DIR}/lib"

rm -rf -- bin lib
cp README TMHMM2.0.html "${TARGET_DIR}"

cd "${TARGET_DIR}"
patch bin/tmhmm tmhmm.patch
sed -i "s~INSERT_BASENAME_HERE~${TARGET_DIR}~" bin/tmhmm
sed -i "s~/usr/local/bin/perl -w~/usr/bin/env -S perl -w~" bin/tmhmmformat.pl
chmod -R a+r .
chmod a+x bin/*

#nb we delete WORKDIR using a trap command in register-base.sh

# Don't change the next two lines
echo "Finished registering ${PKG_NAME}."
echo "Testing installation..."


# Add a command that uses the test dataset included with the package.
# both TEST_RESULT and TEST_RETCODE should be set.
# If you REALLY have to skip tests, set TEST_RETCODE=0.

# If you get a non-zero exit code, the test will fail.
cd "${WORKDIR}"
TEST_RESULT=$(tmhmm < "${TARGET_DIR}/test.fasta")
TEST_RETCODE=$?
