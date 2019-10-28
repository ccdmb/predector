#!/usr/bin/env sh

# Adds some packages to be installed by apt
add_runtime_dep () {
  for dep in ${@}
  do
    echo ${dep} >> "${APT_REQUIREMENTS_FILE}"
  done
}

# Install packages from a file using apt.
apt_install_from_file () {
  for f in ${@}
  do
    xargs -a "${f}" -r -- apt-get install -y --no-install-recommends
  done
}
