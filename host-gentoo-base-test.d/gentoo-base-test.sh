#!/bin/sh
_HOSTNAME='gentoo-base-test'
_USER='user'

configure() {
  source_file 'shared-base.d/shared-base.sh'
  source_file 'gentoo-base.d/gentoo-base.sh'

  get_option '--full' "$@" && (
    run_as_root '/usr/bin/eauto' --unsupervised
    run_as_root eselect news read >/dev/null
    run_as_root '/usr/bin/regenerate-bootloader'
  ) || true

  run_as_root ln -sf /etc/init.d/agetty /etc/init.d/agetty.tty1
  run_as_root rc-update add agetty.tty1 default

  run_as_root rc-update del agetty.tty2 default >/dev/null 2>&1 || true
  run_as_root rc-update del agetty.tty3 default >/dev/null 2>&1 || true
  run_as_root rc-update del agetty.tty4 default >/dev/null 2>&1 || true
  run_as_root rc-update del agetty.tty5 default >/dev/null 2>&1 || true
  run_as_root rc-update del agetty.tty6 default >/dev/null 2>&1 || true
}
