if [ -z "${TEST_RETCODE:-}" ]
then
    echo "Sorry the package author forgot to include a test so this now has to fail." 1>&2
    echo "Please contact the maintainers <darcy.ab.jones@gmail.com>" 1>&2
    exit 1
fi

if [ "${TEST_RETCODE}" -eq 0 ]
then
    echo "Test succeeded."
    echo "${PKG_NAME} is now fully installed!"
else
    echo "ERROR: tests for ${PKG_NAME} failed with exit code ${TEST_RETCODE}." 1>&2
    echo "Please check for any error messages printed to screen." 1>&2
    echo 1>&2

    if [ -z "${TEST_RESULT:-}"]
    then
      echo "STDOUT was:" 1>&2
      echo "${TEST_RESULT:-}" 1>&2
      echo 1>&2
    fi

    echo "If you believe this is a mistake or bug, please contact the maintainers <darcy.ab.jones@gmail.com>" 1>&2
    echo "" 1>&2
    echo "Note that the packages are still copied into the conda environment." 1>&2
    echo "You can rerun '${VEXE}-register' to overwrite these files, or use 'conda uninstall ${PKG_NAME}'." 1>&2
fi
