#!/bin/sh
set -eou pipefail

_DISK=/dev/sda
_ROOT_SIZE=+32G

_HOSTNAME=gs-home
_USER=chuck

_network_interface=enp3s0

_data_fast=sda3,sdb1
_data_slow=sdc1
_data_parity=sdd1

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
  _root_shared kernel-unprivileged-port-start.conf /etc/sysctl.d/unprivileged-port-start.conf
  _root_shared portage-overlays.conf /etc/portage/repos.conf/overlays.conf
  _root_shared portage-package-mask.conf /etc/portage/package.mask
  _root_shared portage-package-unmask.conf /etc/portage/package.unmask
  _root_shared script-dsnap.sh /usr/bin/dsnap
  _root_shared script-duncache.sh /usr/bin/duncache
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
  _root_shared system-podman.conf /etc/containers/containers.conf
  _root_shared system-sshd.conf /etc/ssh/sshd_config.d/key-authentication.conf

  # root host links
  _root_host $_HOSTNAME-firewall.conf /var/lib/nftables/tables/table.conf
  _root_host $_HOSTNAME-interface.conf /etc/conf.d/net
  _root_host $_HOSTNAME-package-declare.conf /etc/portage/package.declare
  _root_host $_HOSTNAME-package-keywords.conf /etc/portage/package.accept_keywords
  _root_host $_HOSTNAME-package-license.conf /etc/portage/package.license
  _root_host $_HOSTNAME-package-use.conf /etc/portage/package.use
  _root_host $_HOSTNAME-services.conf /etc/openrc/services.conf
  _root_host $_HOSTNAME-snapraid.conf /etc/snapraid.conf

  # user shared links
  _user_shared script-bashrc.sh .bashrc

  # user host links
  _user_host $_HOSTNAME-authorized-keys.conf .ssh/authorized_keys
  _user_host $_HOSTNAME-podman-compose.yaml .config/podman/compose.yaml
  _user_host $_HOSTNAME-podman-haproxy.cfg .config/podman/haproxy.cfg

  [ ! -f /etc/init.d/net.$_network_interface ] && link_as_root net.lo /etc/init.d/net.$_network_interface # interface
  [ ! -f /etc/init.d/user.$_USER ] && link_as_root user-runtime /etc/init.d/user.$_USER                   # runtime directory

  get_parameter --install "$@" >/dev/null && {
    run_as_root /usr/bin/eauto --unattended
    run_as_root /usr/bin/eselect news read --quiet all
    run_as_root /usr/bin/installkernel -a

    run_as_root /usr/bin/set-mounts-permissions
    run_as_root sed -i "/# storage/,\$d" /etc/fstab && {
      echo '# storage'
      _i=0 && echo "$_data_fast" | tr , '\n' | while read -r _entry; do
        _i=$((_i + 1))
        _device="/mnt/pool/fast-disk-$(printf "%02d" "$_i")"
        run_as_root mkdir -p "$_device"
        printf 'UUID="%s" ' "$(get_uuid "/dev/${_entry}")"
        printf '%s ext4 ' "$_device"
        printf 'defaults,nodev,nofail,nosuid 0 0\n'
      done
      _i=0 && echo "$_data_slow" | tr , '\n' | while read -r _entry; do
        _i=$((_i + 1))
        _device="/mnt/pool/slow-disk-$(printf "%02d" "$_i")"
        run_as_root mkdir -p "$_device"
        printf 'UUID="%s" ' "$(get_uuid "/dev/${_entry}")"
        printf '%s ext4 ' "$_device"
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
      printf 'UUID="%s" ' "$(get_uuid "/dev/${_data_parity}")"
      printf '%s ext4 ' "$_device"
      printf 'defaults,nodev,nofail,nosuid 0 0\n'
    } | run_as_root tee -a /etc/fstab >/dev/null
  }

  run_as_root /usr/bin/set-mounts-permissions
  run_as_root /usr/bin/setup-openrc
  setup_fcron "$_configure_dots/hosts/$_HOSTNAME/$_HOSTNAME-crontab.conf"
  return 0
}
