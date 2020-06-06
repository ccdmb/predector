# Note: $PKG_* variables are inserted above this line by the build script.
# Note: $ARCHIVE  and TARGET_DIR etc variables are inserted above this line by register-base.

# For most applications this will find the folder that will be extracted from
# the tarball, but some e.g. phobius, will give you weird results.
# Check that this works as expected.
EXTRACTED_DIR_CALLED="$(basename $(tar -tf "${ARCHIVE}" | head -n 1))"

# Don't change the next 3 lines
mkdir -p "${WORKDIR}"
tar --no-same-owner --directory=${WORKDIR} -xf "${ARCHIVE}"


#### Add your code to install here.

cp -r "${WORKDIR}/${EXTRACTED_DIR_CALLED}" "${TARGET_DIR}/src"
cd "${TARGET_DIR}/src"

# Correct source files give version 1.0 this is to keep it consistent.
sed -i "s/version='0.1'/version='1.0'/" ./setup.py

# This patch does three things.
# 1. disable theano warnings. I can't set the log level to error, so i'm just disabling logging.
# 2. Allow users to specify THEANO_FLAGS.
# 3. Add the CXX environment variable to use in THEANO_FLAGS defaults, because otherwise it looks for gcc.
patch bin/deeploc "${TARGET_DIR}/deeploc.patch"

pip install --no-deps --upgrade --force-reinstall --compile --prefix "${ENV_PREFIX}" .

#nb we delete WORKDIR using a trap command in register-base.sh

# Don't change the next two lines
echo "Finished registering ${PKG_NAME}."
echo "Testing installation..."


# Add a command that uses the test dataset included with the package.
# both TEST_RESULT and TEST_RETCODE should be set.
# If you REALLY have to skip tests, set TEST_RETCODE=0.

# If you get a non-zero exit code, the test will fail.
cd "${WORKDIR}"

export THEANO_FLAGS="device=cpu,floatX=float32,optimizer=fast_compile,cxx=${CXX},base_compiledir=${PWD}/theano"
TEST_RESULT=$(deeploc --fasta "${TARGET_DIR}/src/test.fasta" --output "${WORKDIR}/test")
TEST_RETCODE=$?

rm -rf -- "${PWD}/theano"
