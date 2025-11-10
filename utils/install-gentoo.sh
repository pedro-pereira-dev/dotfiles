#!/bin/sh
# shellcheck disable=SC2015 source=/dev/null
set -eou pipefail

_DEFAULT_USER=user
_DEFAULT_BOOT_SIZE=+512M
_DEFAULT_ROOT_SIZE=' '
_DEFAULT_SWAP_SIZE=2G

get_parameter() {
  _NAME='' && [ $# -ge 1 ] && _NAME=$1 && shift
  while [ $# -ge 1 ]; do
    _PARAM=$1 && shift
    if [ "$_NAME" = "$_PARAM" ]; then
      [ $# -ge 1 ] && _VAL=$1 && expr "x$_VAL" : 'x[^-]' >/dev/null && echo "$_VAL"
      return 0
    fi
  done
  return 1
}

_HOSTNAME=$(get_parameter --hostname "$@") && [ -n "$_HOSTNAME" ] ||
  { echo '[E] missing required argument --hostname' && exit 1; }
_PASSWORD=$(get_parameter --password "$@") && [ -n "$_PASSWORD" ] ||
  { echo '[E] missing required argument --password' && exit 1; }
_URL=https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/hosts/$_HOSTNAME/$_HOSTNAME.sh
curl -ILfs "$_URL" >/dev/null && _TMP=$(mktemp) && curl -Lfs "$_URL" -o "$_TMP" && . "$_TMP" ||
  { echo "[E] failed to source $_URL" && exit 1; }

_BOOT_SIZE=${_BOOT_SIZE:-$_DEFAULT_BOOT_SIZE}
_ROOT_SIZE=${_ROOT_SIZE:-$_DEFAULT_ROOT_SIZE}
_SWAP_SIZE=${_SWAP_SIZE:-$_DEFAULT_SWAP_SIZE}

_SMALLEST_DISK=$(lsblk -bdno NAME,SIZE,TYPE | grep disk | sort -nk2 | head -n1 | cut -d' ' -f1)
_DISK=${_DISK:-"/dev/$_SMALLEST_DISK"}
wipefs -a "$_DISK"* && find /dev/disk -type l -exec sh -c '[ ! -e "$1" ] && rm -f "$1" >/dev/null 2>&1' _ {} \;

is_bios() { ! is_uefi; }
is_uefi() { test -d /sys/firmware/efi; }
is_bios && _DISK_LAYOUT="0,n, , , ,$_BOOT_SIZE,a,n, , , ,$_ROOT_SIZE,p,w"
is_uefi && _DISK_LAYOUT="g,n, , ,$_BOOT_SIZE,Y,t,1,n, , ,$_ROOT_SIZE,Y,t, ,23,p,w"
printf '%s' "$_DISK_LAYOUT" | tr , '\n' | fdisk "$_DISK"

get_device_partition() { lsblk -f "$_DISK" -nro NAME,TYPE | grep -E ".*$1 " | cut -d' ' -f1; }
_BOOT_DEV=/dev/$(get_device_partition 1)
_ROOT_DEV=/dev/$(get_device_partition 2)

curl -Lfs -- https://raw.githubusercontent.com/pedro-pereira-dev/gentoo-installer/refs/heads/main/install.sh |
  sh -s -- \
    --hostname "$_HOSTNAME" \
    --password "$_PASSWORD" \
    --boot "$_BOOT_DEV" \
    --root "$_ROOT_DEV" \
    --swap "$_SWAP_SIZE" \
    --keymap pt-latin9 \
    --timezone Europe/Lisbon

_USER=${_USER:-$_DEFAULT_USER}
chroot /mnt /bin/sh <<EOF
env-update && source /etc/profile
useradd -G wheel -m -s /bin/bash $_USER
echo $_USER:$_PASSWORD | chpasswd
emerge -1n --ask=n dev-vcs/git
curl -Lfs -- https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/dots.sh | sh -s -- sync --hostname $_HOSTNAME --user $_USER
EOF
