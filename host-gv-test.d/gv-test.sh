#!/bin/sh
_HOSTNAME='gv-test'
_USER='user'

configure() {
  source_file 'shared-base.d/shared-base.sh'
  source_file 'gentoo-base.d/gentoo-base.sh'

  # get_option '--full' "$@" && (
  #   run_as_root '/usr/bin/eauto' --unsupervised
  #   run_as_root eselect news read >/dev/null
  #   run_as_root '/usr/bin/regenerate-bootloader'
  # ) || true
}
