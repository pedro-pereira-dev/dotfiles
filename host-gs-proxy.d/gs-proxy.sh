#!/bin/sh
_HOSTNAME='gs-proxy'
_USER='chuck'

configure() {
  source_file 'shared-base.d/shared-base.sh'
  source_file 'gentoo-base.d/gentoo-base.sh'

  run_as_root stow "$_HOME/$_DOTS_DIR/host-gs-proxy.d/confs/gs-proxy-declare.conf" '/etc/portage/package.declare/gs-proxy-declare.conf'
  run_as_root stow "$_HOME/$_DOTS_DIR/host-gs-proxy.d/confs/gs-proxy-keywords.conf" '/etc/portage/package.accept_keywords/gs-proxy-keywords.conf'
  run_as_root stow "$_HOME/$_DOTS_DIR/host-gs-proxy.d/confs/gs-proxy-license.conf" '/etc/portage/package.license/gs-proxy-license.conf'
  run_as_root stow "$_HOME/$_DOTS_DIR/host-gs-proxy.d/confs/gs-proxy-unmask.conf" '/etc/portage/package.unmask/gs-proxy-unmask.conf'
  run_as_root stow "$_HOME/$_DOTS_DIR/host-gs-proxy.d/confs/gs-proxy-use.conf" '/etc/portage/package.use/gs-proxy-use.conf'
  run_as_root stow "$_HOME/$_DOTS_DIR/host-gs-proxy.d/confs/kernel-module-ip-tables.conf" '/etc/modules-load.d/ip-tables.conf'
  run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/host-gs-proxy.d/podman" "$_HOME/.podman"

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

  run_as_root rc-update add sshd default >/dev/null 2>&1 || true

  _NETBOOT='/boot/EFI/NETBOOT/NETBOOTAA64.EFI'
  run_as_root rm -f "$_NETBOOT"
  run_as_root mkdir -p "$(dirname $_NETBOOT)"
  run_as_root curl -Lfs https://boot.netboot.xyz/ipxe/netboot.xyz-arm64.efi -o "$_NETBOOT"
}
