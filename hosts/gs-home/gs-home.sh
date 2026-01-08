#!/bin/sh
set -eou pipefail

_DISK=/dev/sda
sync() {
  setup_doas "$_DOTS/files/system-doas.conf"
  delete_links_as_root
  link_as_root "$_DOTS/dots.sh" /usr/bin/dots

  # root shared links
  link_root_shared kernel-unprivileged-port-start.conf /etc/sysctl.d/unprivileged-port-start.conf
  link_root_shared portage-overlays.conf /etc/portage/repos.conf/overlays.conf
  link_root_shared portage-package-mask.conf /etc/portage/package.mask
  link_root_shared portage-package-unmask.conf /etc/portage/package.unmask
  link_root_shared script-dsnap.sh /usr/bin/dsnap
  link_root_shared script-duncache.sh /usr/bin/duncache
  link_root_shared script-eauto.sh /usr/bin/eauto
  link_root_shared script-edeclare.sh /usr/bin/edeclare
  link_root_shared script-edelete.sh /usr/bin/edelete
  link_root_shared script-eupdate.sh /usr/bin/eupdate
  link_root_shared script-eupgrade.sh /usr/bin/eupgrade
  link_root_shared script-set-mounts-permissions.sh /usr/bin/set-mounts-permissions
  link_root_shared script-setup-openrc.sh /usr/bin/setup-openrc
  link_root_shared service-nftables.conf /etc/conf.d/nftables
  link_root_shared service-user-runtime.sh /etc/init.d/user-runtime
  link_root_shared system-grub.conf /etc/default/grub
  link_root_shared system-nftables.conf /var/lib/nftables/rules-save
  link_root_shared system-podman.conf /etc/containers/containers.conf
  link_root_shared system-sshd.conf /etc/ssh/sshd_config.d/key-authentication.conf

  # root host links
  link_root_host "$_HOSTNAME-firewall.conf" /var/lib/nftables/tables/table.conf
  link_root_host "$_HOSTNAME-interface.conf" /etc/conf.d/net
  link_root_host "$_HOSTNAME-package-declare.conf" /etc/portage/package.declare
  link_root_host "$_HOSTNAME-package-keywords.conf" /etc/portage/package.accept_keywords
  link_root_host "$_HOSTNAME-package-license.conf" /etc/portage/package.license
  link_root_host "$_HOSTNAME-package-use.conf" /etc/portage/package.use
  link_root_host "$_HOSTNAME-services.conf" /etc/openrc/services.conf
  link_root_host "$_HOSTNAME-snapraid.conf" /etc/snapraid.conf

  # user shared links
  link_user_shared script-bashrc.sh .bashrc

  # user host links
  link_user_host "$_HOSTNAME-authorized-keys.conf" .ssh/authorized_keys
  link_user_host "$_HOSTNAME-podman-compose.yaml" .config/podman/compose.yaml
  link_user_host "$_HOSTNAME-podman-haproxy.cfg" .config/podman/haproxy.cfg

  [ ! -f /etc/init.d/net.enp3s0 ] && link_as_root net.lo /etc/init.d/net.enp3s0       # interface
  [ ! -f /etc/init.d/user.chuck ] && link_as_root user-runtime /etc/init.d/user.chuck # runtime directory

  get_parameter --full "$@" >/dev/null && {
    run_as_root /usr/bin/eauto --unattended
    run_as_root /usr/bin/eselect news read --quiet all
    run_as_root /usr/bin/installkernel -a

    ! grep -q "^shared:" /etc/group &&
      run_as_root groupadd -g 9999 shared &&
      run_as_root usermod -aG shared chuck

    # wip

    run_as_root rm -fr /mnt &&
      run_as_root mkdir -p /mnt &&
      run_as_root chgrp shared /mnt &&
      run_as_root chmod g+s /mnt &&
      run_as_root setfacl -d -m g:shared:rwx /mnt &&
      run_as_root setfacl -m g:shared:rwx /mnt

    # run_as_root /usr/bin/set-mounts-permissions
    run_as_root sed -i "/# custom/,\$d" /etc/fstab && {
      echo '# custom'
      _i=0 && echo sda3,sdb1 | tr , '\n' | while read -r _entry; do
        _i=$((_i + 1))
        _device="/mnt/pool/fast-disk-$(printf "%02d" "$_i")"
        run_as_root mkdir -p "$_device"
        printf 'UUID="%s" %s ext4 ' "$(get_uuid "/dev/${_entry}")" "$_device"
        printf 'defaults,nodev,nofail,nosuid 0 0\n'
      done
      _i=0 && echo sdc1 | tr , '\n' | while read -r _entry; do
        _i=$((_i + 1))
        _device="/mnt/pool/slow-disk-$(printf "%02d" "$_i")"
        run_as_root mkdir -p "$_device"
        printf 'UUID="%s" %s ext4 ' "$(get_uuid "/dev/${_entry}")" "$_device"
        printf 'defaults,nodev,nofail,nosuid 0 0\n'
      done
      _device=/mnt/pool/fast-storage
      run_as_root mkdir -p "$_device"
      printf '/mnt/pool/fast-disk-* '
      printf '%s mergerfs ' $_device
      printf 'defaults\n'
      _device=/mnt/pool/slow-storage
      run_as_root mkdir -p "$_device"
      printf '/mnt/pool/slow-disk-* '
      printf '%s mergerfs ' $_device
      printf 'defaults\n'
      _device=/mnt/data
      run_as_root mkdir -p "$_device"
      printf '/mnt/pool/fast-disk-*:/mnt/pool/slow-disk-* '
      printf '%s mergerfs ' $_device
      printf 'defaults,category.create=ff\n'
      _device=/mnt/parity
      run_as_root mkdir -p "$_device"
      printf 'UUID="%s" ' "$(get_uuid /dev/sdd1)"
      printf '%s ext4 ' "$_device"
      printf 'defaults,nodev,nofail,nosuid 0 0\n'
    } | run_as_root tee -a /etc/fstab >/dev/null
  }

  # wip

  # run_as_root /usr/bin/set-mounts-permissions
  run_as_root /usr/bin/setup-openrc
  setup_fcron "$_configure_dots/hosts/$_HOSTNAME/$_HOSTNAME-crontab.conf"
  return 0
}
