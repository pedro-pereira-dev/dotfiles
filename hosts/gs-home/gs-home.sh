#!/bin/sh
set -eou pipefail

_DISK=/dev/sda
sync() {
  ! is_root && run_as_root "$_DOTS/dots.sh" sync "$@"
  ! is_root && return $?

  setup_doas "$_DOTS/files/system-doas.conf"
  delete_links_as_root
  link_as_root "$_DOTS/dots.sh" /usr/bin/dots

  # root shared links
  link_root_shared kernel-unprivileged-port-start.conf /etc/sysctl.d/unprivileged-port-start.conf
  link_root_shared portage-overlays.conf /etc/portage/repos.conf/overlays.conf
  link_root_shared portage-package-mask.conf /etc/portage/package.mask
  link_root_shared script-dbackup.sh /usr/bin/dbackup
  link_root_shared script-dsnap.sh /usr/bin/dsnap
  link_root_shared script-duncache.sh /usr/bin/duncache
  link_root_shared script-eauto.sh /usr/bin/eauto
  link_root_shared script-edeclare.sh /usr/bin/edeclare
  link_root_shared script-edelete.sh /usr/bin/edelete
  link_root_shared script-eupdate.sh /usr/bin/eupdate
  link_root_shared script-eupgrade.sh /usr/bin/eupgrade
  link_root_shared service-nftables.conf /etc/conf.d/nftables
  link_root_shared service-user-runtime.sh /etc/init.d/user-runtime
  link_root_shared system-grub.conf /etc/default/grub
  link_root_shared system-nftables.conf /var/lib/nftables/rules-save
  link_root_shared system-podman-containers.conf /etc/containers/containers.conf
  link_root_shared system-sshd.conf /etc/ssh/sshd_config.d/key-authentication.conf

  # root host links
  link_root_host "$_HOSTNAME-network.conf" /etc/conf.d/net
  link_root_host "$_HOSTNAME-nftables.conf" /var/lib/nftables/tables/default.conf
  link_root_host "$_HOSTNAME-package-declare.conf" /etc/portage/package.declare
  link_root_host "$_HOSTNAME-package-keywords.conf" /etc/portage/package.accept_keywords
  link_root_host "$_HOSTNAME-package-license.conf" /etc/portage/package.license
  link_root_host "$_HOSTNAME-package-use.conf" /etc/portage/package.use
  link_root_host "$_HOSTNAME-podman-acme-entrypoint.sh" /etc/podman/acme-entrypoint.sh
  link_root_host "$_HOSTNAME-podman-authelia-entrypoint.sh" /etc/podman/authelia-entrypoint.sh
  link_root_host "$_HOSTNAME-podman-authelia.yml" /etc/podman/authelia.yml
  link_root_host "$_HOSTNAME-podman-compose.yaml" /etc/podman/compose.yaml
  link_root_host "$_HOSTNAME-podman-haproxy.cfg" /etc/podman/haproxy.cfg
  link_root_host "$_HOSTNAME-podman-lldap.toml" /etc/podman/lldap.toml
  link_root_host "$_HOSTNAME-podman-valkey.conf" /etc/podman/valkey.conf
  link_root_host "$_HOSTNAME-podman-vaultwarden.env" /etc/podman/vaultwarden.env
  link_root_host "$_HOSTNAME-snapraid.conf" /etc/snapraid.conf

  # user shared links
  link_user_shared script-bashrc.sh .bashrc

  # user host links
  link_user_host "$_HOSTNAME-sshd-authorized-keys.conf" .ssh/authorized_keys

  [ ! -f /etc/init.d/net.enp3s0 ] && link_as_root net.lo /etc/init.d/net.enp3s0       # interface
  [ ! -f /etc/init.d/user.chuck ] && link_as_root user-runtime /etc/init.d/user.chuck # runtime directory

  [ ! -e /etc/podman/storage ] && run_as_root ln -fsv "/mnt/data/managed/$_HOSTNAME/podman" /etc/podman/storage

  get_parameter --full "$@" >/dev/null && {
    run_as_root /usr/bin/eauto --unattended
    run_as_root /usr/bin/eselect news read --quiet all
    run_as_root /usr/bin/installkernel -a

    ! id -u podman >/dev/null 2>&1 &&
      run_as_root useradd -md /var/lib/podman -rs /usr/bin/nologin -u 200 podman &&
      run_as_root usermod --add-subgids 200000-265535 podman &&
      run_as_root usermod --add-subuids 200000-265535 podman

    ! grep -q ^shared: /etc/group &&
      run_as_root groupadd -g 9999 shared &&
      run_as_root usermod -aG shared chuck &&
      run_as_root usermod -aG shared podman

    run_as_root sed -i "/# custom/,\$d" /etc/fstab && {
      echo '# custom'
      echo "UUID=\"$(get_uuid /dev/sda3)\" /mnt/pool/fast-disk-01 ext4 defaults,nodev,nofail,nosuid 0 0"
      echo "UUID=\"$(get_uuid /dev/sdb1)\" /mnt/pool/fast-disk-02 ext4 defaults,nodev,nofail,nosuid 0 0"
      echo "UUID=\"$(get_uuid /dev/sdc1)\" /mnt/pool/slow-disk-01 ext4 defaults,nodev,nofail,nosuid 0 0"
      echo '/mnt/pool/fast-disk-* /mnt/pool/fast-storage mergerfs defaults 0 0'
      echo '/mnt/pool/slow-disk-* /mnt/pool/slow-storage mergerfs defaults 0 0'
      echo '/mnt/pool/fast-disk-*:/mnt/pool/slow-disk-* /mnt/data mergerfs defaults,category.create=ff 0 0'
      echo "UUID=\"$(get_uuid /dev/sdd1)\" /mnt/parity ext4 defaults,nodev,nofail,nosuid 0 0"
    } | run_as_root tee -a /etc/fstab >/dev/null

    run_as_root mkdir -p \
      /mnt/pool/fast-disk-01 \
      /mnt/pool/fast-disk-02 \
      /mnt/pool/slow-disk-01 \
      /mnt/pool/fast-storage \
      /mnt/pool/slow-storage \
      /mnt/data \
      /mnt/parity

    run_as_root mount -a
    run_as_root chgrp -R shared /mnt
    run_as_root chmod -R g=rwx,g+s /mnt
  }

  setup_fcron "$_DOTS/hosts/$_HOSTNAME/$_HOSTNAME-crontab.conf"
  setup_openrc "$_DOTS/hosts/$_HOSTNAME/$_HOSTNAME-services.conf"

  # might not work during installation
  [ -d /mnt/data/managed/gs-home/podman/haproxy/data ] && {
    run_as_user chuck \
      curl -Lfs https://raw.githubusercontent.com/TimWolla/haproxy-auth-request/refs/heads/main/auth-request.lua \
      -o /mnt/data/managed/gs-home/podman/haproxy/data/auth-request.lua
    run_as_user chuck \
      curl -Lfs https://raw.githubusercontent.com/haproxytech/haproxy-lua-http/refs/heads/master/http.lua \
      -o /mnt/data/managed/gs-home/podman/haproxy/data/haproxy-lua-http.lua
    run_as_user chuck \
      curl -Lfs https://raw.githubusercontent.com/rxi/json.lua/refs/heads/master/json.lua \
      -o /mnt/data/managed/gs-home/podman/haproxy/data/json.lua
  }

  return 0
}
