#!/bin/sh
# shellcheck disable=SC2015 source=/dev/null
set -eou pipefail

_DEFAULT_USER=user
_DEFAULT_BOOT_SIZE=+512M
_DEFAULT_ROOT_SIZE=' '
_DEFAULT_SWAP_SIZE=1G

get_device_partition() { lsblk -f "$_DISK" -nro NAME,TYPE | grep -E ".*$1 " | cut -d' ' -f1; }

get_parameter() {
  _FLAG='' && [ $# -ge 1 ] && _FLAG=$1 && shift
  while [ $# -ge 1 ]; do
    _PARAM='' && [ $# -ge 1 ] && _PARAM=$1 && shift
    [ "$_FLAG" = "$_PARAM" ] && {
      _VAL='' && [ $# -ge 1 ] && _VAL=$1
      # prints out value if it does not start with -
      [ -n "$_VAL" ] && expr "x$_VAL" : 'x[^-]' >/dev/null && echo "$_VAL"
      return 0
    }
  done
  return 1
}

is_bios() { ! is_uefi; }
is_uefi() { test -d /sys/firmware/efi; }

_HOSTNAME=$(get_parameter --hostname "$@") && [ -n "$_HOSTNAME" ] ||
  { echo '[E] missing required argument --hostname' && exit 1; }
_PASSWORD=$(get_parameter --password "$@") && [ -n "$_PASSWORD" ] ||
  { echo '[E] missing required argument --password' && exit 1; }

_URL=https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/hosts/$_HOSTNAME/$_HOSTNAME.sh
# sources host configuration from dotfiles github repository
curl -ILfs "$_URL" >/dev/null && _TMP=$(mktemp) && curl -Lfs "$_URL" -o "$_TMP" && . "$_TMP" ||
  { echo "[E] failed to source $_URL" && exit 1; }

_USER=${_USER:-$_DEFAULT_USER}

_BOOT_SIZE=${_BOOT_SIZE:-$_DEFAULT_BOOT_SIZE}
_ROOT_SIZE=${_ROOT_SIZE:-$_DEFAULT_ROOT_SIZE}
_SWAP_SIZE=${_SWAP_SIZE:-$_DEFAULT_SWAP_SIZE}

_SMALLEST_DISK=$(lsblk -bdno NAME,SIZE,TYPE | grep disk | sort -nk2 | head -n1 | cut -d' ' -f1)
_DISK=${_DISK:-"/dev/$_SMALLEST_DISK"}

# removes all partitions and mapped devices
wipefs -a "$_DISK"* && find /dev/disk -type l -exec sh -c '[ ! -e "$1" ] && rm -f "$1" >/dev/null 2>&1' _ {} \;

is_bios && _DISK_LAYOUT="0,n, , , ,$_BOOT_SIZE,a,n, , , ,$_ROOT_SIZE,p,w"
is_uefi && _DISK_LAYOUT="g,n, , ,$_BOOT_SIZE,Y,t,1,n, , ,$_ROOT_SIZE,Y,p,w"
printf '%s' "$_DISK_LAYOUT" | tr , '\n' | fdisk "$_DISK"

_BOOT_DEV=/dev/$(get_device_partition 1)
_ROOT_DEV=/dev/$(get_device_partition 2)

curl -Lfs -o /tmp/install.sh \
  https://raw.githubusercontent.com/pedro-pereira-dev/gentoo-installer/refs/heads/main/install.sh
sh /tmp/install.sh \
  --hostname "$_HOSTNAME" \
  --password "$_PASSWORD" \
  --boot "$_BOOT_DEV" \
  --root "$_ROOT_DEV" \
  --swap "$_SWAP_SIZE" \
  --keymap pt-latin9 \
  --timezone Europe/Lisbon || true

chroot /mnt /bin/bash <<EOF
env-update && source /etc/profile

useradd -G wheel -m -s /bin/bash $_USER
echo $_USER:$_PASSWORD | chpasswd

emerge --ask=n -1n dev-vcs/git
curl -Lfs -o /tmp/dots.sh https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/dots.sh
sh /tmp/dots.sh sync --full --hostname $_HOSTNAME --user $_USER

/usr/bin/installkernel -a
/usr/bin/edelete --unattended
EOF
