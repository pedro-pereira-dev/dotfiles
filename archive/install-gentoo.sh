#!/bin/sh
# shellcheck disable=SC2015 source=/dev/null
set -eou pipefail

is_uefi() { test -d /sys/firmware/efi; }
is_bios() { ! is_uefi; }

get_device_partition() { _get_device_partition_dev=$1 && _get_device_partition_part=$2 &&
  lsblk -f "$_get_device_partition_dev" -nro NAME,TYPE |
  grep -E ".*$_get_device_partition_part " | cut -d' ' -f1; }

get_parameter() {
  _get_parameter_flag=$1 && shift
  while [ $# -ge 1 ]; do
    _get_parameter_param=$1 && shift
    [ "$_get_parameter_flag" != "$_get_parameter_param" ] && continue
    _get_parameter_val='' && [ $# -ge 1 ] && _get_parameter_val=$1
    [ -n "$_get_parameter_val" ] &&
      expr "x$_get_parameter_val" : 'x[^-]' >/dev/null &&
      echo "$_get_parameter_val"
    return 0
  done
  return 1
}

_hostname=$(get_parameter --hostname "$@") && [ -n "$_hostname" ] ||
  { echo '[E] missing required argument --hostname' && exit 1; }
_password=$(get_parameter --password "$@") && [ -n "$_password" ] ||
  { echo '[E] missing required argument --password' && exit 1; }

_branch=$(get_parameter --branch "$@") && [ -n "$_branch" ] || _branch=main
_url=$(get_parameter --url "$@") && [ -n "$_url" ] || _url=https://raw.githubusercontent.com

_dots_repo=$(get_parameter --repository "$@") && [ -n "$_dots_repo" ] ||
  _dots_repo=pedro-pereira-dev/dotfiles

_conf=$_url/$_dots_repo/refs/heads/$_branch/hosts/$_hostname/$_hostname.sh
# sources host configuration from dotfiles github repository
curl -ILfs "$_url" >/dev/null &&
  _tmp=$(mktemp) && curl -Lfs "$_url" -o "$_tmp" && . "$_tmp" ||
  { echo "[E] failed to source $_url" && exit 1; }

_DISK=${_DISK:-''} && [ -n "$_DISK" ] ||
  { echo '[E] missing required variable _DISK' && exit 1; }

wipefs -a "$_DISK"*
# removes mapped devices
find /dev/disk -type l -exec sh -c '[ ! -e "$1" ] && rm -f "$1"' _ {} \;

_BOOT_SIZE=${_BOOT_SIZE:-+1G}
_ROOT_SIZE=${_ROOT_SIZE:-+32G}
_SWAP_SIZE=${_SWAP_SIZE:-4G}

is_bios && _disk_layout="0,n, , , ,$_BOOT_SIZE,a,n, , , ,$_ROOT_SIZE" &&
  [ "$_ROOT_SIZE" != ' ' ] && _disk_layout="${_disk_layout},n, , , , "
is_uefi && _disk_layout="g,n, , ,$_BOOT_SIZE,Y,t,1,n, , ,$_ROOT_SIZE,Y" &&
  [ "$_ROOT_SIZE" != ' ' ] && _disk_layout="${_disk_layout},n, , , ,Y"
printf '%s' "${_disk_layout},p,w" | tr , '\n' | fdisk "$_DISK"

_boot_dev=/dev/$(get_device_partition "$_DISK" 1)
_root_dev=/dev/$(get_device_partition "$_DISK" 2)

[ "$_ROOT_SIZE" != ' ' ] &&
  { mkfs.ext4 -F "/dev/$(get_device_partition "$_DISK" 3)" || exit 1; }

_installer_repo=$(get_parameter --installer-repository "$@") && [ -n "$_installer_repo" ] ||
  _installer_repo=pedro-pereira-dev/gentoo-installer

curl -Lfs "$_url/$_installer_repo/refs/heads/$_branch/install.sh" -o /tmp/install.sh
yes | sh /tmp/install.sh \
  --hostname "$_hostname" \
  --password "$_password" \
  --boot "$_boot_dev" \
  --root "$_root_dev" \
  --swap "$_SWAP_SIZE" \
  --keymap pt-latin9 \
  --timezone Europe/Lisbon || true

_user=${_user:-chuck}
chroot /mnt /bin/bash <<EOF
env-update && source /etc/profile

useradd -G wheel -ms /usr/bin/bash $_user
echo $_user:$_password | chpasswd

emerge --ask=n -1n dev-vcs/git
curl -Lfs -- $_url/$_dots_repo/refs/heads/$_branch/dots.sh | 
  sh -s -- sync --full --hostname $_hostname --user $_user
EOF
