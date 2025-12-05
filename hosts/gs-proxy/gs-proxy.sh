#!/bin/sh
set -eou pipefail

_USER=chuck

configure() {
  _configure_home=$(get_home $_USER) && _configure_dots="$_configure_home/workspace/personal/dotfiles"
  setup_doas "$_configure_dots/files/system-doas.conf"
  get_parameter --full "$@" >/dev/null && delete_links_as_root
  link_as_root "$_configure_dots/dots.sh" /usr/bin/dots

  # shared root links
  link_as_root "$_configure_dots/files/openrc-nftables.conf" /etc/conf.d/nftables
  link_as_root "$_configure_dots/files/portage-overlays.conf" /etc/portage/repos.conf/overlays.conf
  link_as_root "$_configure_dots/files/portage-package-mask.conf" /etc/portage/package.mask
  link_as_root "$_configure_dots/files/portage-package-unmask.conf" /etc/portage/package.unmask
  link_as_root "$_configure_dots/files/script-eauto.sh" /usr/bin/eauto
  link_as_root "$_configure_dots/files/script-edeclare.sh" /usr/bin/edeclare
  link_as_root "$_configure_dots/files/script-edelete.sh" /usr/bin/edelete
  link_as_root "$_configure_dots/files/script-eupdate.sh" /usr/bin/eupdate
  link_as_root "$_configure_dots/files/script-eupgrade.sh" /usr/bin/eupgrade
  link_as_root "$_configure_dots/files/script-nft-trust-ip.sh" /usr/bin/nft-trust-ip
  link_as_root "$_configure_dots/files/script-setup-services.sh" /usr/bin/setup-services
  link_as_root "$_configure_dots/files/service-podman-compose.sh" /etc/init.d/podman-compose
  link_as_root "$_configure_dots/files/service-podman-socket.sh" /etc/init.d/podman-socket
  link_as_root "$_configure_dots/files/service-user-runtime.sh" /etc/init.d/user-runtime
  link_as_root "$_configure_dots/files/sshd-key-authentication.conf" /etc/ssh/sshd_config.d/key-authentication.conf
  link_as_root "$_configure_dots/files/system-grub.conf" /etc/default/grub
  link_as_root "$_configure_dots/files/system-nftables.conf" /var/lib/nftables/rules-save
  link_as_root "$_configure_dots/files/system-podman.conf" /etc/containers/containers.conf

  # host root links
  link_as_root "$_configure_dots/hosts/gs-proxy/nftables-default-table.conf" /var/lib/nftables/tables/table.conf
  link_as_root "$_configure_dots/hosts/gs-proxy/openrc-net-online.conf" /etc/conf.d/net-online
  link_as_root "$_configure_dots/hosts/gs-proxy/openrc-services.conf" /etc/openrc/services.conf
  link_as_root "$_configure_dots/hosts/gs-proxy/portage-package-declare.conf" /etc/portage/package.declare
  link_as_root "$_configure_dots/hosts/gs-proxy/portage-package-keywords.conf" /etc/portage/package.accept_keywords
  link_as_root "$_configure_dots/hosts/gs-proxy/portage-package-license.conf" /etc/portage/package.license
  link_as_root "$_configure_dots/hosts/gs-proxy/portage-package-use.conf" /etc/portage/package.use
  link_as_root "$_configure_dots/hosts/gs-proxy/sshd-gateway-ports.conf" /etc/ssh/sshd_config.d/gateway-ports.conf

  # shared user links
  link_as_user $_USER "$_configure_dots/files/script-bashrc.sh" "$_configure_home/.bashrc"

  # host user links
  link_as_user $_USER "$_configure_dots/hosts/gs-proxy/podman-compose.yaml" "$_configure_home/.podman/compose.yaml"
  link_as_user $_USER "$_configure_dots/hosts/gs-proxy/podman-haproxy.cfg" "$_configure_home/.podman/haproxy.cfg"
  link_as_user $_USER "$_configure_dots/hosts/gs-proxy/sshd-authorized-keys.conf" "$_configure_home/.ssh/authorized_keys"

  [ ! -f /etc/init.d/agetty.ttyAMA0 ] && link_as_root agetty /etc/init.d/agetty.ttyAMA0                       # console
  [ ! -f /etc/init.d/podman-compose.$_USER ] && link_as_root podman-compose /etc/init.d/podman-compose.$_USER # compose up on boot
  [ ! -f /etc/init.d/podman-socket.$_USER ] && link_as_root podman-socket /etc/init.d/podman-socket.$_USER    # podman socket
  [ ! -f /etc/init.d/user.$_USER ] && link_as_root user-runtime /etc/init.d/user.$_USER                       # runtime directory

  get_parameter --full "$@" >/dev/null && {
    run_as_root /usr/bin/eauto --unattended
    run_as_root /usr/bin/eselect news read --quiet all
    run_as_root /usr/bin/setup-services podman-compose.$_USER podman-socket.$_USER
  }

  [ ! -f /efi/EFI/netboot/netboot.xyz-arm64.efi ] &&
    run_as_root rm -fr /efi/EFI/netboot &&
    run_as_root mkdir -p /efi/EFI/netboot &&
    run_as_root curl -Lfs https://boot.netboot.xyz/ipxe/netboot.xyz-arm64.efi -o /efi/EFI/netboot/netboot.xyz-arm64.efi

  return 0
}
