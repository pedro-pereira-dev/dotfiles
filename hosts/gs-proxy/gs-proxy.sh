#!/bin/sh
# shellcheck source=/dev/null
set -eou pipefail

_HOSTNAME='gs-proxy'
_USER='chuck'

configure() {
  run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/dots" "$_HOME/.local/bin/dots"
  run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/overlays/dots/files/system-bashrc.sh" "$_HOME/.bashrc"

  is_gentoo && {
    run_as_root stow "$_HOME/$_DOTS_DIR/overlays/dots/files/dots-package-declare.conf" /etc/portage/package.declare/1-dots-declare.conf
  } || true

  . "$_HOME/$_DOTS_DIR/overlays/dots/dots.sh"
  . "$_HOME/$_DOTS_DIR/overlays/gentoo-base/gentoo-base.sh"
  . "$_HOME/$_DOTS_DIR/overlays/gentoo-server/gentoo-server.sh"

  run_as_root stow "$_HOME/$_DOTS_DIR/hosts/gs-proxy/files/gs-proxy-package-declare.conf" /etc/portage/package.declare/4-gs-proxy-declare.conf
  run_as_root stow "$_HOME/$_DOTS_DIR/hosts/gs-proxy/files/gs-proxy-package-keywords.conf" /etc/portage/package.accept_keywords/4-gs-proxy-keywords.conf
  run_as_root stow "$_HOME/$_DOTS_DIR/hosts/gs-proxy/files/gs-proxy-package-use.conf" /etc/portage/package.use/4-gs-proxy-use.conf

  # run_as_root stow "$_SCRIPT_DIR/layer-podman-unprivileged-port-start.conf" '/etc/sysctl.d/unprivileged-port-start.conf'
  # run_as_root stow "$_HOME/$_DOTS_DIR/hosts/gs-proxy/files/kernel-module-ip-tables.conf" /etc/modules-load.d/ip-tables.conf

  run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/hosts/gs-proxy/podman" "$_HOME/.podman"

  get_option '--full' "$@" && (
    run_as_root /usr/bin/eauto --unsupervised
    run_as_root eselect news read >/dev/null
    # run_as_root /usr/bin/installkernel
  ) || true

  _NETBOOT='/efi/EFI/NETBOOT/netboot.xyz-arm64.efi'
  run_as_root rm -f "$_NETBOOT"
  run_as_root mkdir -p "$(dirname $_NETBOOT)"
  run_as_root curl -Lfs https://boot.netboot.xyz/ipxe/netboot.xyz-arm64.efi -o "$_NETBOOT"
}
