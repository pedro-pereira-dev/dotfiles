#!/bin/sh
# shellcheck disable=SC2015 source=/dev/null
set -eou pipefail

is_uefi() { test -d /sys/firmware/efi; }
is_bios() { ! is_uefi; }

get_parameter() {
  _get_parameter_flag=$1 && shift
  while [ $# -ge 1 ]; do
    _get_parameter_param=$1 && shift
    [ "$_get_parameter_flag" = "$_get_parameter_param" ] && {
      _get_parameter_val='' && [ $# -ge 1 ] && _get_parameter_val=$1
      # prints out if not starting by -
      [ -n "$_get_parameter_val" ] && expr "x$_get_parameter_val" : 'x[^-]' >/dev/null &&
        echo "$_get_parameter_val" || true
    } && return 0
  done && return 1
}

_hostname=$(get_parameter --hostname "$@") && [ -n "$_hostname" ] ||
  { echo '[E] missing required argument --hostname' && exit 1; }
_password=$(get_parameter --password "$@") && [ -n "$_password" ] ||
  { echo '[E] missing required argument --password' && exit 1; }

# sources host configuration from dotfiles github repository
_url=https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/hosts/$_hostname/$_hostname.sh
curl -ILfs "$_url" >/dev/null && _tmp=$(mktemp) && curl -Lfs "$_url" -o "$_tmp" && . "$_tmp" ||
  { echo "[E] failed to source $_url" && exit 1; }

_USER=${_USER:-user}

_BOOT_SIZE=${_BOOT_SIZE:-+512M}
_ROOT_SIZE=${_ROOT_SIZE:-' '}
_SWAP_SIZE=${_SWAP_SIZE:-1G}

_smallest_disk=$(lsblk -bdno NAME,SIZE,TYPE | grep disk | sort -nk2 | head -n1 | cut -d' ' -f1)
_DISK=${_DISK:-/dev/$_smallest_disk}

# removes all partitions and mapped devices
wipefs -a "$_DISK"* && find /dev/disk -type l -exec sh -c '[ ! -e "$1" ] && rm -f "$1"' _ {} \;

is_bios && _disk_layout="0,n, , , ,$_BOOT_SIZE,a,n, , , ,$_ROOT_SIZE,p,w"
is_uefi && _disk_layout="g,n, , ,$_BOOT_SIZE,Y,t,1,n, , ,$_ROOT_SIZE,Y,p,w"
printf '%s' "$_disk_layout" | tr , '\n' | fdisk "$_DISK"

get_device_partition() {
  _get_device_partition_dev=$1 && _get_device_partition_part=$2
  lsblk -f "$_get_device_partition_dev" -nro NAME,TYPE | grep -E ".*$_get_device_partition_part " | cut -d' ' -f1
}

_boot_dev=/dev/$(get_device_partition "$_DISK" 1)
_root_dev=/dev/$(get_device_partition "$_DISK" 2)

curl -Lfs https://raw.githubusercontent.com/pedro-pereira-dev/gentoo-installer/refs/heads/main/install.sh -o /tmp/install.sh
yes | sh /tmp/install.sh \
  --hostname "$_hostname" \
  --password "$_password" \
  --boot "$_boot_dev" \
  --root "$_root_dev" \
  --swap "$_SWAP_SIZE" \
  --keymap pt-latin9 \
  --timezone Europe/Lisbon || true

chroot /mnt /bin/bash <<EOF
env-update && source /etc/profile

useradd -G wheel -ms /usr/bin/bash $_USER
echo $_USER:$_password | chpasswd

emerge --ask=n -1n dev-vcs/git
curl -Lfs https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/dots.sh -o /tmp/dots.sh 
sh /tmp/dots.sh sync --install --hostname $_hostname --user $_USER
EOF
