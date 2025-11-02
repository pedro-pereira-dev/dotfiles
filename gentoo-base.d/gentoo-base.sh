#!/bin/sh
set -eou pipefail

run_as_root stow "$_HOME/$_DOTS_DIR/gentoo-base.d/gentoo-tools/" '/usr/bin/'
# run_as_root stow "$_HOME/$_DOTS_DIR/gentoo-base.d/system-confs/grub.conf" '/etc/default/grub'
run_as_root stow "$_HOME/$_DOTS_DIR/gentoo-base.d/system-confs/overlays.conf" '/etc/portage/repos.conf/overlays.conf'
run_as_root stow "$_HOME/$_DOTS_DIR/gentoo-base.d/system-confs/package.mask" '/etc/portage/package.mask'

! check_command doas && run_as_root emerge --ask=n --noreplace app-admin/doas || true
check_command doas &&
  run_as_root cp -f "$_HOME/$_DOTS_DIR/gentoo-base.d/system-confs/doas.conf" '/etc/doas.conf' &&
  run_as_root chmod u=rw,go= /etc/doas.conf &&
  run_as_root chown root:root /etc/doas.conf &&
  run_as_root passwd -dl root >/dev/null 2>&1
