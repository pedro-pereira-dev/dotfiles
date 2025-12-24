#!/bin/sh
set -eou pipefail

_DISK=/dev/sda
_ROOT_SIZE=+16G
sync() {
  ! is_root && run_as_root "$_DOTS/dots.sh" sync "$@"
  ! is_root && return $?

  setup_doas "$_DOTS/files/system-doas.conf"
  delete_links_as_root
  link_as_root "$_DOTS/dots.sh" /usr/bin/dots

  # root shared links
  link_root_shared portage-overlays.conf /etc/portage/repos.conf/overlays.conf
  link_root_shared portage-package-mask.conf /etc/portage/package.mask
  link_root_shared script-eauto.sh /usr/bin/eauto
  link_root_shared script-edeclare.sh /usr/bin/edeclare
  link_root_shared script-edelete.sh /usr/bin/edelete
  link_root_shared script-eupdate.sh /usr/bin/eupdate
  link_root_shared script-eupgrade.sh /usr/bin/eupgrade
  link_root_shared service-nftables.conf /etc/conf.d/nftables
  link_root_shared service-user-runtime.sh /etc/init.d/user-runtime
  link_root_shared system-grub.conf /etc/default/grub
  link_root_shared system-nftables.conf /var/lib/nftables/rules-save
  link_root_shared system-sshd.conf /etc/ssh/sshd_config.d/key-authentication.conf

  # root host links
  link_root_host "$_HOSTNAME-nftables.conf" /var/lib/nftables/tables/default.conf
  link_root_host "$_HOSTNAME-package-declare.conf" /etc/portage/package.declare
  link_root_host "$_HOSTNAME-package-keywords.conf" /etc/portage/package.accept_keywords
  link_root_host "$_HOSTNAME-package-license.conf" /etc/portage/package.license
  link_root_host "$_HOSTNAME-package-use.conf" /etc/portage/package.use

  # user shared links
  link_user_shared script-bashrc.sh .bashrc

  # user host links
  link_user_host "$_HOSTNAME-sshd-authorized-keys.conf" .ssh/authorized_keys

  [ ! -f /etc/init.d/agetty.ttyAMA0 ] && link_as_root agetty /etc/init.d/agetty.ttyAMA0 # console
  [ ! -f /etc/init.d/user.chuck ] && link_as_root user-runtime /etc/init.d/user.chuck   # runtime directory

  get_parameter --full "$@" >/dev/null && {
    run_as_root /usr/bin/eauto --unattended
    run_as_root /usr/bin/eselect news read --quiet all
    run_as_root /usr/bin/installkernel -a

    ! grep -q ^shared: /etc/group &&
      run_as_root groupadd -g 9999 shared &&
      run_as_root usermod -aG shared chuck

    run_as_root sed -i "/# custom/,\$d" /etc/fstab && {
      echo '# custom'
      echo "UUID=\"$(get_uuid /dev/sda3)\" /mnt/gs-home ext4 defaults,nodev,nofail,nosuid 0 0"
    } | run_as_root tee -a /etc/fstab >/dev/null

    run_as_root mkdir -p \
      /mnt/gs-home

    run_as_root mount -a
    run_as_root chgrp -R shared /mnt
    run_as_root chmod -R g=rwx,g+s /mnt
  }

  setup_fcron "$_DOTS/hosts/$_HOSTNAME/$_HOSTNAME-crontab.conf"
  setup_openrc "$_DOTS/hosts/$_HOSTNAME/$_HOSTNAME-services.conf"

  [ ! -f /efi/EFI/netboot/netboot.xyz-arm64.efi ] &&
    run_as_root rm -fr /efi/EFI/netboot &&
    run_as_root mkdir -p /efi/EFI/netboot &&
    run_as_root curl -Lfs https://boot.netboot.xyz/ipxe/netboot.xyz-arm64.efi -o /efi/EFI/netboot/netboot.xyz-arm64.efi

  return 0
}
