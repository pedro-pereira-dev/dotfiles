#!/bin/sh
set -eou pipefail

run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-server/files/gentoo-server-package-declare.conf" /etc/portage/package.declare/3-gentoo-server-declare.conf
run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-server/files/nftables-tables-ssh-filter.conf" /var/lib/nftables/tables/ssh-filter.conf
run_as_root stow "$_HOME/$_DOTS_DIR/overlays/gentoo-server/files/system-sshd.conf" /etc/ssh/sshd_config.d/gentoo-sshd.conf

# ! check_command nft && {
#   run_as_root emerge --ask=n -n net-firewall/nftables
# } || true
# run_as_root rc-update add nftables default >/dev/null

! check_command sshd && {
  run_as_root emerge --ask=n -n net-misc/openssh
} || true
run_as_root rc-update add sshd default >/dev/null
