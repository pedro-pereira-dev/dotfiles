#!/bin/sh
set -eou pipefail

_USER=chuck

configure() {
  _HOME=$(get_home $_USER) && _DOTS="$_HOME/workspace/personal/dotfiles"
  setup_doas "$_DOTS/files/system-doas.conf"

  _PODMAN_USER=podman && _PODMAN_HOME=$(get_home $_PODMAN_USER)
  create_user $_PODMAN_USER
  run_as_root usermod -aG $_PODMAN_USER $_USER

  get_parameter --full "$@" >/dev/null && delete_links_as_root
  link_as_root "$_DOTS/dots.sh" /usr/bin/dots

  # shared root links
  link_as_root "$_DOTS/files/openrc-net-online.conf" /etc/conf.d/net-online
  link_as_root "$_DOTS/files/portage-overlays.conf" /etc/portage/repos.conf/overlays.conf
  link_as_root "$_DOTS/files/portage-package-mask.conf" /etc/portage/package.mask
  link_as_root "$_DOTS/files/script-eauto.sh" /usr/bin/eauto
  link_as_root "$_DOTS/files/script-edeclare.sh" /usr/bin/edeclare
  link_as_root "$_DOTS/files/script-edelete.sh" /usr/bin/edelete
  link_as_root "$_DOTS/files/script-eupdate.sh" /usr/bin/eupdate
  link_as_root "$_DOTS/files/script-eupgrade.sh" /usr/bin/eupgrade
  link_as_root "$_DOTS/files/script-nft-trust-ip.sh" /usr/bin/nft-trust-ip
  link_as_root "$_DOTS/files/script-setup-services.sh" /usr/bin/setup-services
  link_as_root "$_DOTS/files/service-podman-compose.sh" /etc/init.d/podman-compose
  link_as_root "$_DOTS/files/service-podman-socket.sh" /etc/init.d/podman-socket
  link_as_root "$_DOTS/files/service-user-runtime.sh" /etc/init.d/user-runtime
  link_as_root "$_DOTS/files/system-grub.conf" /etc/default/grub
  link_as_root "$_DOTS/files/system-nftables.conf" /var/lib/nftables/rules-save
  link_as_root "$_DOTS/files/system-podman.conf" /etc/containers/containers.conf
  link_as_root "$_DOTS/files/system-sshd.conf" /etc/ssh/sshd_config.d/sshd.conf

  # shared user links
  link_as_user $_USER "$_DOTS/files/script-bashrc.sh" "$_HOME/.bashrc"

  # host root links
  link_as_root "$_DOTS/hosts/gs-proxy/nftables-default-table.conf" /var/lib/nftables/tables/table.conf
  link_as_root "$_DOTS/hosts/gs-proxy/openrc-services.conf" /etc/openrc/services.conf
  link_as_root "$_DOTS/hosts/gs-proxy/portage-package-declare.conf" /etc/portage/package.declare
  link_as_root "$_DOTS/hosts/gs-proxy/portage-package-keywords.conf" /etc/portage/package.accept_keywords
  link_as_root "$_DOTS/hosts/gs-proxy/portage-package-license.conf" /etc/portage/package.license
  link_as_root "$_DOTS/hosts/gs-proxy/portage-package-unmask.conf" /etc/portage/package.unmask
  link_as_root "$_DOTS/hosts/gs-proxy/portage-package-use.conf" /etc/portage/package.use

  # host user links
  link_as_user $_USER "$_DOTS/hosts/gs-proxy/ssh-authorized-keys.conf" "$_HOME/.ssh/authorized_keys"

  # host podman links
  link_as_user $_PODMAN_USER "$_DOTS/hosts/gs-proxy/podman-compose.yaml" "$_PODMAN_HOME/.podman/compose.yaml"

  [ ! -f /etc/init.d/agetty.ttyAMA0 ] && link_as_root agetty /etc/init.d/agetty.ttyAMA0                                     # console
  [ ! -f /etc/init.d/podman-compose.$_PODMAN_USER ] && link_as_root podman-compose /etc/init.d/podman-compose.$_PODMAN_USER # user podman socket
  [ ! -f /etc/init.d/podman-socket.$_PODMAN_USER ] && link_as_root podman-socket /etc/init.d/podman-socket.$_PODMAN_USER    # user compose on boot
  [ ! -f /etc/init.d/user.$_PODMAN_USER ] && link_as_root user-runtime /etc/init.d/user.$_PODMAN_USER                       # podman user runtime directory
  [ ! -f /etc/init.d/user.$_USER ] && link_as_root user-runtime /etc/init.d/user.$_USER                                     # host user runtime directory

  get_parameter --full "$@" >/dev/null && {
    run_as_root /usr/bin/eauto --unattended
    run_as_root /usr/bin/eselect news read --quiet all
    run_as_root /usr/bin/setup-services podman-compose.$_PODMAN_USER podman-socket.$_PODMAN_USER
  }

  [ ! -f /efi/EFI/netboot/netboot.xyz-arm64.efi ] &&
    run_as_root rm -fr /efi/EFI/netboot &&
    run_as_root mkdir -p /efi/EFI/netboot &&
    run_as_root curl -Lfs https://boot.netboot.xyz/ipxe/netboot.xyz-arm64.efi -o /efi/EFI/netboot/netboot.xyz-arm64.efi

  return 0
}
