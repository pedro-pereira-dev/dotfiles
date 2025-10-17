#!/bin/sh
_HOSTNAME='gentoo-server-oracle'
_USER='chuck'

configure() {
  source_file 'shared-base.d/shared-base.sh'
  source_file 'gentoo-base.d/gentoo-base.sh'

  run_as_root stow "$_HOME/$_DOTS_DIR/host-gentoo-server-oracle.d/confs/gentoo-server-oracle-declare.conf" '/etc/portage/package.declare/gentoo-server-oracle-declare.conf'
  run_as_root stow "$_HOME/$_DOTS_DIR/host-gentoo-server-oracle.d/confs/gentoo-server-oracle-keywords.conf" '/etc/portage/package.accept_keywords/gentoo-server-oracle-keywords.conf'
  run_as_root stow "$_HOME/$_DOTS_DIR/host-gentoo-server-oracle.d/confs/gentoo-server-oracle-license.conf" '/etc/portage/package.license/gentoo-server-oracle-license.conf'
  run_as_root stow "$_HOME/$_DOTS_DIR/host-gentoo-server-oracle.d/confs/gentoo-server-oracle-unmask.conf" '/etc/portage/package.unmask/gentoo-server-oracle-unmask.conf'
  run_as_root stow "$_HOME/$_DOTS_DIR/host-gentoo-server-oracle.d/confs/gentoo-server-oracle-use.conf" '/etc/portage/package.use/gentoo-server-oracle-use.conf'
  run_as_root stow "$_HOME/$_DOTS_DIR/host-gentoo-server-oracle.d/confs/kernel-module-ip-tables.conf" '/etc/modules-load.d/ip-tables.conf'
  run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/host-gentoo-server-oracle.d/podman" "$_HOME/.podman"

  get_option '--full' "$@" && (
    run_as_root '/usr/bin/eauto' --unsupervised
    run_as_root eselect news read >/dev/null
    run_as_root '/usr/bin/regenerate-bootloader'
  ) || true

  run_as_root rc-update del agetty.tty2 default >/dev/null 2>&1 || true
  run_as_root rc-update del agetty.tty3 default >/dev/null 2>&1 || true
  run_as_root rc-update del agetty.tty4 default >/dev/null 2>&1 || true
  run_as_root rc-update del agetty.tty5 default >/dev/null 2>&1 || true
  run_as_root rc-update del agetty.tty6 default >/dev/null 2>&1 || true

  run_as_root rc-update add sshd default >/dev/null 2>&1 || true

  _NETBOOT='/efi/EFI/netboot/netboot.xyz-arm64.efi'
  run_as_root rm -f "$_NETBOOT"
  run_as_root mkdir -p "$(dirname $_NETBOOT)"
  run_as_root curl -Lfs https://boot.netboot.xyz/ipxe/netboot.xyz-arm64.efi -o "$_NETBOOT"
}
