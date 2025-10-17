#!/bin/sh
set -eou

is_bios && _BOOT_FLAG='boot'
is_bios && _PART_TABLE='msdos'

is_uefi && _BOOT_FLAG='esp'
is_uefi && _PART_TABLE='gpt'

_HOSTNAME=${_HOSTNAME:-'gentoo-system-undefined'}
_USER=${_USER:-'user'}

_BOOT_SIZE=${_BOOT_SIZE:-'1'}    # gb
_SWAP_SIZE=${_SWAP_SIZE:-'4'}    # gb
_ROOT_SIZE=${_ROOT_SIZE:-'100%'} # remaining space

is_default_root_size() { test "$_ROOT_SIZE" = '100%'; }

_BOOT_SECTOR_SIZE=$(calculate_size_in_sectors "$_BOOT_SIZE")
_SWAP_SECTOR_SIZE=$(calculate_size_in_sectors "$_SWAP_SIZE")
! is_default_root_size && _ROOT_SECTOR_SIZE=$(calculate_size_in_sectors "$_ROOT_SIZE") || true

_BOOT_END_SECTOR=$((2048 + _BOOT_SECTOR_SIZE - 1))
_SWAP_START_SECTOR=$(calculate_next_aligned_sector "$_BOOT_END_SECTOR")
_SWAP_END_SECTOR=$((_SWAP_START_SECTOR + _SWAP_SECTOR_SIZE - 1))
_ROOT_START_SECTOR=$(calculate_next_aligned_sector "$_SWAP_END_SECTOR") || true
! is_default_root_size && _ROOT_END_SECTOR=$((_ROOT_START_SECTOR + _ROOT_SECTOR_SIZE - 1)) || true

! is_default_root_size && _PARTED_ROOT_SIZE="$_ROOT_END_SECTOR"s || true
is_default_root_size && _PARTED_ROOT_SIZE="$_ROOT_SIZE" || true

get_smallest_device() { lsblk -bdno NAME,SIZE | awk '/^(sd|nvme)/ {print "/dev/"$1" "$2}' | sort -nk2 | head -n1 | cut -d' ' -f1; }
_DEV=${_DEV:-"$(get_smallest_device)"}

wipefs -a "$_DEV"*
parted -a optimal -s "$_DEV" \
  unit s \
  mklabel "$_PART_TABLE" \
  mkpart primary "2048"s "$_BOOT_END_SECTOR"s \
  set 1 "$_BOOT_FLAG" on name 1 _BOOT \
  mkpart primary "$_SWAP_START_SECTOR"s "$_SWAP_END_SECTOR"s \
  name 2 _SWAP \
  mkpart primary "$_ROOT_START_SECTOR"s "$_PARTED_ROOT_SIZE" \
  name 3 _ROOT \
  print

get_partuuid() { blkid | grep "$(readlink -f "$1")" | grep -o 'PARTUUID="[^"]*"' | cut -d'"' -f2; }
_BOOT_DEV="/dev/disk/by-partuuid/$(get_partuuid /dev/disk/by-partlabel/_BOOT)"
_SWAP_DEV="/dev/disk/by-partuuid/$(get_partuuid /dev/disk/by-partlabel/_SWAP)"
_ROOT_DEV="/dev/disk/by-partuuid/$(get_partuuid /dev/disk/by-partlabel/_ROOT)"

_COUNTER=0
while [ $_COUNTER -lt 5 ]; do
  [ -b "$_BOOT_DEV" ] && [ -b "$_SWAP_DEV" ] && [ -b "$_ROOT_DEV" ] && break || true
  [ $_COUNTER -ge 5 ] && exit 1 || true
  _COUNTER=$((_COUNTER + 1)) && sleep 1
  _BOOT_DEV="/dev/disk/by-partuuid/$(get_partuuid /dev/disk/by-partlabel/_BOOT)"
  _SWAP_DEV="/dev/disk/by-partuuid/$(get_partuuid /dev/disk/by-partlabel/_SWAP)"
  _ROOT_DEV="/dev/disk/by-partuuid/$(get_partuuid /dev/disk/by-partlabel/_ROOT)"
done

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
