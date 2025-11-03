#!/bin/sh
# shellcheck source=/dev/null
set -eou pipefail

get_option() {
  _OPT='' && [ "$#" -ge 1 ] && _OPT="$1" && shift
  while [ "$#" -gt 0 ]; do
    _ARG="$1" && shift
    if [ "$_OPT" = "$_ARG" ]; then
      [ "$#" -gt 0 ] && expr "x$1" : 'x[^-]' >/dev/null && echo "$1"
      return 0
    fi
  done
  return 1
}

_HOSTNAME="$(get_option '--hostname' "$@")" && [ -n "$_HOSTNAME" ] ||
  (echo "[E] missing required argument '--hostname'" && exit 1)
_PASSWORD="$(get_option '--password' "$@")" && [ -n "$_PASSWORD" ] ||
  (echo "[E] missing required argument '--password'" && exit 1)

_DOTS_RAW_URL='https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main'
_FILE="hosts/$_HOSTNAME/$_HOSTNAME.sh"

source_local_file() { _PWD=$(dirname "$(readlink -f "$0")") && [ -f "$_PWD/$1" ] && . "$_PWD/$1"; }
source_remote_file() {
  curl -ILfs "$_DOTS_RAW_URL/$1" >/dev/null && _TMP_FILE=$(mktemp) &&
    curl -Lfs -o "$_TMP_FILE" "$_DOTS_RAW_URL/$1" && . "$_TMP_FILE"
}

! source_local_file "$_FILE" && ! source_remote_file "$_FILE" &&
  echo "[E] failed to source '$_FILE'" && exit 1

_SMALLEST_DEV=$(lsblk -bdno NAME,SIZE,TYPE | grep disk | sort -nk2 | head -n1 | cut -d' ' -f1)
_DEV=${_DEV:-"/dev/$_SMALLEST_DEV"}

wipefs -a "$_DEV"*
find /dev/disk -type l -exec sh -c '[ ! -e "$1" ] && rm -f "$1" >/dev/null 2>&1' _ {} \;

is_bios() { ! is_uefi; }
is_uefi() { test -d '/sys/firmware/efi'; }

_BOOT_SIZE=${_BOOT_SIZE:-'+512M'}
_ROOT_SIZE=${_ROOT_SIZE:-' '} # remaining space
_SWAP_SIZE=${_SWAP_SIZE:-'4G'}

is_bios &&
  sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' <<EOF | fdisk "$_DEV"
    o  # dos partition table
    n  # new partition
       # default partition type
       # default partition number
       # default first sector
    $_BOOT_SIZE
    a  # bootable flag
    n  # new partition
       # default partition type
       # default partition number
       # default first sector
    $_ROOT_SIZE
    p  # print table
    w  # write
EOF
is_uefi &&
  sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' <<EOF | fdisk "$_DEV"
    g  # gpt partition table
    n  # new partition
       # default partition number
       # default first sector
    $_BOOT_SIZE
    Y  # delete partition signature
    t  # set partition type
    1  # type efi
    n  # new partition
       # default partition number
       # default first sector
    $_ROOT_SIZE
    Y  # delete partition signature
    t  # set partition type
       # default partition number
    23 # type linux root
    p  # print table
    w  # write
EOF

get_device_partition() { lsblk -f "$_DEV" -nro NAME,TYPE | grep -E "$_SMALLEST_DEV.*$1 " | cut -d' ' -f1; }
_BOOT_DEV="/dev/$(get_device_partition 1)"
_ROOT_DEV="/dev/$(get_device_partition 2)"

_TMP_FILE=$(mktemp) && curl -Lfs -o "$_TMP_FILE" \
  'https://raw.githubusercontent.com/pedro-pereira-dev/gentoo-installer/refs/heads/main/install.sh'
sh "$_TMP_FILE" \
  --hostname "$_HOSTNAME" \
  --password "$_PASSWORD" \
  --boot "$_BOOT_DEV" \
  --root "$_ROOT_DEV" \
  --swap "$_SWAP_SIZE" \
  --keymap 'pt-latin9' \
  --timezone 'Europe/Lisbon'

_USER=${_USER:-'user'}
chroot /mnt /bin/sh <<EOF
env-update && source /etc/profile
useradd -m -G wheel -s /bin/bash "$_USER"
echo "$_USER:$_PASSWORD" | chpasswd
emerge -1n --ask=n net-misc/curl
_TMP_FILE=\$(mktemp) && curl -Lfs -o \$_TMP_FILE $_DOTS_RAW_URL/dots
sh \$_TMP_FILE sync --full
EOF
