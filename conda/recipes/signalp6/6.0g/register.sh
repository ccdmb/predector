# Note: $PKG_* variables are inserted above this line by the build script.
# Note: $ARCHIVE  and TARGET_DIR etc variables are inserted above this line by register-base.

# For most applications this will find the folder that will be extracted from
# the tarball, but some e.g. phobius, will give you weird results.
# Check that this works as expected.
EXTRACTED_DIR_CALLED="signalp6_fast" # signalp-6-package
# "$(basename $(tar -tf "${ARCHIVE}" | head -n 1))"

# Don't change the next 3 lines
mkdir -p "${WORKDIR}"
tar --no-same-owner --directory=${WORKDIR} -xzf "${ARCHIVE}"
cd "${WORKDIR}"


if [ ! -d "${EXTRACTED_DIR_CALLED}" ]
then
    if [ -d "signalp6_slow_sequential" ]
    then
        echo "This SignalP6 distribution appears to be for the 'slow_sequential' version." 1>&2
        echo "We only support the 'fast' version." 1>&2
        echo "Please download the 'fast' version from <https://services.healthtech.dtu.dk/service.php?SignalP-6.0> " 1>&2
        echo "and try running this command again." 1>&2
    else
        echo "This SignalP6 distribution does not conform to the structure that we expected for this version." 1>&2
        echo "Please double check that you have downloaded the 'fast' version from <https://services.healthtech.dtu.dk/service.php?SignalP-6.0>." 1>&2
    fi

    echo "" 1>&2
    echo "If you have definitely downloaded the fast model and are still getting this issue, please contact us: " 1>&2
    echo "- https://github.com/ccdmb/predector/issues" 1>&2
    echo "- darcy.ab.jones@gmail.com" 1>&2
    echo "" 1>&2
    echo "Sorry for the bother" 1>&2
    exit 1
fi

cd "${EXTRACTED_DIR_CALLED}"


#### Add your code to install here.

python3 -m pip install ./signalp-6-package/ -vv --no-deps --compile
SIGNALP_DIR=$(python3 -c "import signalp; import os; print(os.path.dirname(signalp.__file__))" )

mkdir -p "${SIGNALP_DIR}/model_weights"

if [ -d "./signalp-6-package/models/" ]
then
  cp -r ./signalp-6-package/models/* "${SIGNALP_DIR}/model_weights/"
fi


if [ ! -f "${SIGNALP_DIR}/model_weights/distilled_model_signalp6.pt" ]
then
  echo "This distribution of SignalP6 appears to be missing the 'fast' models. " 1>&2
  echo "Please make sure that you have downloaded the 'fast' version, and not the 'slow_sequential' one." 1>&2
  echo "If you have downloaded the correct model and still recieve this error, please report the issue to us, as the SignalP6 package may have changed." 1>&2
  echo "- https://github.com/ccdmb/predector/issues" 1>&2
  echo "- darcy.ab.jones@gmail.com" 1>&2
  exit 1
fi

signalp6_convert_models cpu

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
