#!/bin/sh
set -eou pipefail

_DISK=/dev/sda
_ROOT_SIZE=+16G

_HOSTNAME=gs-proxy
_USER=chuck

_backups_gs_home=sda3

configure() {
  _configure_home=$(get_home $_USER)
  _configure_dots="$_configure_home/workspace/personal/dotfiles"

  _root_host() { link_as_root "$_configure_dots/hosts/$_HOSTNAME/$1" "$2"; }
  _root_shared() { link_as_root "$_configure_dots/files/$1" "$2"; }
  _user_host() { link_as_user "$_USER" "$_configure_dots/hosts/$_HOSTNAME/$1" "$_configure_home/$2"; }
  _user_shared() { link_as_user "$_USER" "$_configure_dots/files/$1" "$_configure_home/$2"; }

  setup_doas "$_configure_dots/files/system-doas.conf"
  delete_links_as_root
  link_as_root "$_configure_dots/dots.sh" /usr/bin/dots

  # root shared links
  _root_shared portage-overlays.conf /etc/portage/repos.conf/overlays.conf
  _root_shared portage-package-mask.conf /etc/portage/package.mask
  _root_shared portage-package-unmask.conf /etc/portage/package.unmask
  _root_shared script-eauto.sh /usr/bin/eauto
  _root_shared script-edeclare.sh /usr/bin/edeclare
  _root_shared script-edelete.sh /usr/bin/edelete
  _root_shared script-eupdate.sh /usr/bin/eupdate
  _root_shared script-eupgrade.sh /usr/bin/eupgrade
  _root_shared script-set-mounts-permissions.sh /usr/bin/set-mounts-permissions
  _root_shared script-setup-openrc.sh /usr/bin/setup-openrc
  _root_shared service-nftables.conf /etc/conf.d/nftables
  _root_shared service-user-runtime.sh /etc/init.d/user-runtime
  _root_shared system-grub.conf /etc/default/grub
  _root_shared system-nftables.conf /var/lib/nftables/rules-save
  _root_shared system-sshd.conf /etc/ssh/sshd_config.d/key-authentication.conf

  # root host links
  _root_host $_HOSTNAME-firewall.conf /var/lib/nftables/tables/table.conf
  _root_host $_HOSTNAME-package-declare.conf /etc/portage/package.declare
  _root_host $_HOSTNAME-package-keywords.conf /etc/portage/package.accept_keywords
  _root_host $_HOSTNAME-package-license.conf /etc/portage/package.license
  _root_host $_HOSTNAME-package-use.conf /etc/portage/package.use
  _root_host $_HOSTNAME-services.conf /etc/openrc/services.conf

  # user shared links
  _user_shared script-bashrc.sh .bashrc

  # user host links
  _user_host $_HOSTNAME-authorized-keys.conf .ssh/authorized_keys

  [ ! -f /etc/init.d/agetty.ttyAMA0 ] && link_as_root agetty /etc/init.d/agetty.ttyAMA0 # console
  [ ! -f /etc/init.d/user.$_USER ] && link_as_root user-runtime /etc/init.d/user.$_USER # runtime directory

  get_parameter --install "$@" >/dev/null && {
    run_as_root /usr/bin/eauto --unattended
    run_as_root /usr/bin/eselect news read --quiet all
    run_as_root /usr/bin/installkernel -a

    run_as_root /usr/bin/set-mounts-permissions
    run_as_root sed -i "/# storage/,\$d" /etc/fstab && {
      echo '# storage'
      _device=/mnt/backups/gs-home
      run_as_root mkdir -p "$_device"
      printf 'UUID="%s" ' "$(get_uuid "/dev/$_backups_gs_home")"
      printf '%s ext4 ' "$_device"
      printf 'defaults,nodev,nofail,nosuid 0 0\n'
    } | run_as_root tee -a /etc/fstab >/dev/null
  }

  run_as_root /usr/bin/setup-openrc
  setup_fcron "$_configure_dots/hosts/$_HOSTNAME/$_HOSTNAME-crontab.conf"

  [ ! -f /efi/EFI/netboot/netboot.xyz-arm64.efi ] &&
    run_as_root rm -fr /efi/EFI/netboot &&
    run_as_root mkdir -p /efi/EFI/netboot &&
    run_as_root curl -Lfs https://boot.netboot.xyz/ipxe/netboot.xyz-arm64.efi -o /efi/EFI/netboot/netboot.xyz-arm64.efi

  return 0
}
