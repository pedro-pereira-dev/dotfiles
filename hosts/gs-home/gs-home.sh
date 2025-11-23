#!/bin/sh
set -eou pipefail

_DISK=/dev/sda
_HOSTNAME=gs-home
_USER=chuck

configure() {
  setup_doas
  get_parameter --full "$@" >/dev/null && delete_links_as_root
  link_as_root "$_HOME/workspace/personal/dotfiles/dots.sh" /usr/bin/dots

  link_as_root "$_HOME/workspace/personal/dotfiles/files/system-grub.conf" /etc/default/grub
  link_as_root "$_HOME/workspace/personal/dotfiles/files/system-nftables-nft-trust-ip.sh" /usr/bin/nft-trust-ip
  link_as_root "$_HOME/workspace/personal/dotfiles/files/system-nftables.conf" /var/lib/nftables/rules-save
  link_as_root "$_HOME/workspace/personal/dotfiles/files/system-openrc-podman-restart.conf" /etc/conf.d/podman-restart
  link_as_root "$_HOME/workspace/personal/dotfiles/files/system-openrc-rdeclare.sh" /usr/bin/rdeclare
  link_as_root "$_HOME/workspace/personal/dotfiles/files/system-podman-netavark-nftables.conf" /etc/containers/containers.conf.d/netavark-nftables.conf
  link_as_root "$_HOME/workspace/personal/dotfiles/files/system-portage-eauto.sh" /usr/bin/eauto
  link_as_root "$_HOME/workspace/personal/dotfiles/files/system-portage-edeclare.sh" /usr/bin/edeclare
  link_as_root "$_HOME/workspace/personal/dotfiles/files/system-portage-edelete.sh" /usr/bin/edelete
  link_as_root "$_HOME/workspace/personal/dotfiles/files/system-portage-eupdate.sh" /usr/bin/eupdate
  link_as_root "$_HOME/workspace/personal/dotfiles/files/system-portage-eupgrade.sh" /usr/bin/eupgrade
  link_as_root "$_HOME/workspace/personal/dotfiles/files/system-portage-overlays.conf" /etc/portage/repos.conf/overlays.conf
  link_as_root "$_HOME/workspace/personal/dotfiles/files/system-portage-package-mask.conf" /etc/portage/package.mask
  link_as_root "$_HOME/workspace/personal/dotfiles/files/system-sshd.conf" /etc/ssh/sshd_config.d/sshd.conf

  link_as_root "$_HOME/workspace/personal/dotfiles/hosts/gs-home/gs-home-nftables.conf" /var/lib/nftables/tables/filter.conf
  link_as_root "$_HOME/workspace/personal/dotfiles/hosts/gs-home/gs-home-openrc-declare.conf" /etc/openrc/declare.conf
  link_as_root "$_HOME/workspace/personal/dotfiles/hosts/gs-home/gs-home-portage-package-declare.conf" /etc/portage/package.declare
  link_as_root "$_HOME/workspace/personal/dotfiles/hosts/gs-home/gs-home-portage-package-keywords.conf" /etc/portage/package.accept_keywords
  link_as_root "$_HOME/workspace/personal/dotfiles/hosts/gs-home/gs-home-portage-package-license.conf" /etc/portage/package.license
  link_as_root "$_HOME/workspace/personal/dotfiles/hosts/gs-home/gs-home-portage-package-unmask.conf" /etc/portage/package.unmask
  link_as_root "$_HOME/workspace/personal/dotfiles/hosts/gs-home/gs-home-portage-package-use.conf" /etc/portage/package.use

  link_as_root "$_HOME/workspace/personal/dotfiles/files/user-bashrc.sh" "$_HOME/.bashrc"

  link_as_user "$_HOME/workspace/personal/dotfiles/hosts/gs-home/gs-home-podman-compose.yaml" "$_HOME/.podman/compose.yaml"
  link_as_user "$_HOME/workspace/personal/dotfiles/hosts/gs-home/gs-home-ssh-authorized-keys.conf" "$_HOME/.ssh/authorized_keys"

  get_parameter --full "$@" >/dev/null && {
    run_as_root /usr/bin/eauto --unattended
    run_as_root /usr/bin/installkernel -a
    run_as_root eselect news read --quiet all
    run_as_root /usr/bin/rdeclare
  }

  # { get_parameter --full "$@" >/dev/null; } && {
  #   run_as_user podman-compose -f "$_HOME/.podman/compose.yaml" pull
  #   run_as_user podman-compose -f "$_HOME/.podman/compose.yaml" up -d --force-recreate --remove-orphans
  #   run_as_user podman ps -a
  # }

  [ ! -f /efi/EFI/netboot/netboot.xyz-arm64.efi ] &&
    run_as_root rm -fr /efi/EFI/netboot &&
    run_as_root mkdir -p /efi/EFI/netboot &&
    run_as_root curl -Lfs https://boot.netboot.xyz/ipxe/netboot.xyz-arm64.efi -o /efi/EFI/netboot/netboot.xyz-arm64.efi

  return 0
}
