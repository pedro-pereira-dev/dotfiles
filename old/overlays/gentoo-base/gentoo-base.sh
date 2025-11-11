#!/bin/sh
set -eou pipefail

run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/gentoo-base-package-declare.conf" /etc/portage/package.declare/2-gentoo-base-declare.conf
run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/gentoo-base-package-mask.conf" /etc/portage/package.mask/2-gentoo-base-mask.conf
run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/gentoo-base-package-use.conf" /etc/portage/package.use/2-gentoo-base-use.conf
run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/nftables-main.conf" /var/lib/nftables/rules-save
run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/nftables-tables-default-filter.conf" /var/lib/nftables/tables/default-filter.conf
run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/portage-eauto.sh" /usr/bin/eauto
run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/portage-edeclare.sh" /usr/bin/edeclare
run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/portage-edelete.sh" /usr/bin/edelete
run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/portage-eupdate.sh" /usr/bin/eupdate
run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/portage-eupgrade.sh" /usr/bin/eupgrade
run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/portage-overlays.conf" /etc/portage/repos.conf/overlays.conf
run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/system-grub.conf" /etc/default/grub
run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/system-inittab.conf" /etc/inittab

! check_command doas && {
  run_as_root emerge --ask=n -n app-admin/doas
} || true
check_command doas && {
  run_as_root cp -f "$_HOME/$_DOTS_DIR/overlays/gentoo-base/files/system-doas.conf" /etc/doas.conf
  run_as_root chmod u=rw,go= /etc/doas.conf && run_as_root chown root:root /etc/doas.conf
  run_as_root passwd -dl root >/dev/null 2>&1
} || true

# ! check_command nft && {
#   run_as_root emerge --ask=n -n net-firewall/nftables
# } || true
# run_as_root rc-update add nftables default >/dev/null
