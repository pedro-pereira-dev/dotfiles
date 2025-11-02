#!/bin/sh
set -eou pipefail

! check_command doas && run_as_root emerge --ask=n app-admin/doas || true
check_command doas &&
  run_as_root cp -f "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/doas.conf" /etc/doas.conf &&
  run_as_root chmod u=rw,go= /etc/doas.conf && run_as_root chown root:root /etc/doas.conf &&
  run_as_root passwd -dl root >/dev/null 2>&1 || true

run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/configuration-grub.conf" /etc/default/grub
run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/configuration-overlays.conf" /etc/portage/repos.conf/overlays.conf
run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/gentoo-base-package-declare.conf" /etc/portage/package.declare/1-gentoo-base-declare.conf
run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/gentoo-base-package-mask.conf" /etc/portage/package.mask/1-gentoo-base-mask.conf
run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/gentoo-regenerate-bootloader.sh" /usr/bin/regenerate-bootloader
run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/portage-eauto.sh" /usr/bin/eauto
run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/portage-edeclare.sh" /usr/bin/edeclare
run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/portage-edelete.sh" /usr/bin/edelete
run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/portage-eupdate.sh" /usr/bin/eupdate
run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/portage-eupgrade.sh" /usr/bin/eupgrade
