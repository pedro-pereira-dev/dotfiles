#!/bin/sh
set -eou pipefail

_HOSTNAME=${_HOSTNAME:-'gentoo-system-undefined'}
_USER=${_USER:-'user'}

_BOOT_SIZE=${_BOOT_SIZE:-'+1G'}
_SWAP_SIZE=${_SWAP_SIZE:-'+4G'}
_ROOT_SIZE=${_ROOT_SIZE:-' '} # remaining space

get_smallest_device() { lsblk -bdno NAME,SIZE,TYPE | grep disk | sort -nk2 | head -n1 | cut -d' ' -f1; }
_DEV=${_DEV:-"/dev/$(get_smallest_device)"}

wipefs -a "$_DEV"*
if is_bios; then
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
    $_SWAP_SIZE
    t  # set partition type
       # default partition number
    82 # type linux swap
    n  # new partition
       # default partition type
       # default partition number
       # default first sector
    $_ROOT_SIZE
    p  # print table
    w  # write
EOF
else
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
    $_SWAP_SIZE
    Y  # delete partition signature
    t  # set partition type
       # default partition number
    19 # type linux swap
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
fi

get_partuuid() { blkid | grep -E "$_DEV.*$1:" | grep -o 'PARTUUID="[^"]*"' | cut -d'"' -f2; }
_BOOT_DEV="/dev/disk/by-partuuid/$(get_partuuid 1)" || exit 1
_SWAP_DEV="/dev/disk/by-partuuid/$(get_partuuid 2)" || exit 1
_ROOT_DEV="/dev/disk/by-partuuid/$(get_partuuid 3)" || exit 1

_TMP_FILE=$(mktemp)
curl -Lfs 'https://raw.githubusercontent.com/pedro-pereira-dev/gentoo-installer/refs/heads/main/install.sh' >"$_TMP_FILE"
sh "$_TMP_FILE" \
  --hostname "$_HOSTNAME" \
  --password "$_PASSWORD" \
  --boot "$_BOOT_DEV" \
  --swap "$_SWAP_DEV" \
  --root "$_ROOT_DEV" \
  --keymap 'pt-latin9' \
  --timezone 'Europe/Lisbon'

chroot /mnt /bin/sh <<EOF
env-update && source /etc/profile
useradd -m -G wheel -s /bin/bash "$_USER"
echo "$_USER:$_PASSWORD" | chpasswd
emerge -1n --ask=n net-misc/curl
curl -Lfs "$_DOTS_RAW_URL/dots" | sh -s -- sync --full
EOF
