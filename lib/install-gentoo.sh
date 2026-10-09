#!/usr/bin/env bash
# shellcheck disable=SC2016

install_gentoo_git() {
  if command -v git >/dev/null; then return 0; fi
  sudo emaint sync -A && sudo emerge --ask=n -1n dev-vcs/git && return 0
  return 1
}

install_gentoo_portage_config() {
  _ram_gb=$(awk '/MemTotal/ {print int($2 / 1048576)}' /proc/meminfo)
  _ram_jobs=$((_ram_gb / 2))

  _make_jobs=$(nproc)
  if [ "$_make_jobs" -gt "$_ram_jobs" ]; then _make_jobs=$_ram_jobs; fi
  if [ "$_make_jobs" -lt 1 ]; then _make_jobs=1; fi

  sudo mkdir -p /etc/portage/env
  echo '*/* dots-make.conf' | sudo tee -a /etc/portage/package.env >/dev/null
  {
    echo '# compiler flags targetting system'
    echo 'RUSTFLAGS="$RUSTFLAGS -C target-cpu=native"'
    echo 'COMMON_FLAGS="-march=native -O2 -pipe"'
    echo 'CFLAGS="$COMMON_FLAGS"'
    echo 'CXXFLAGS="$COMMON_FLAGS"'
    echo 'FCFLAGS="$COMMON_FLAGS"'
    echo 'FFLAGS="$COMMON_FLAGS"'
    echo ''
    echo '# quiet fetches'
    echo 'FETCHCOMMAND="$FETCHCOMMAND -q"'
    echo 'RESUMECOMMAND="$RESUMECOMMAND -q"'
    echo ''
    echo '# portage default options'
    echo "EMERGE_DEFAULT_OPTS=\"-aqv --jobs $_make_jobs --load-average $_make_jobs\""
    echo 'FEATURES="$FEATURES binpkg-request-signature getbinpkg"'
    echo "MAKEOPTS=\"--jobs $_make_jobs --load-average $_make_jobs\""
    echo ''
    echo 'USE="dist-kernel systemd systemd-boot uki ukify"'
  } | sudo tee /etc/portage/env/dots-make.conf >/dev/null
}
