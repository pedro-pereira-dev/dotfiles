#!/bin/sh
set -eou pipefail

_HOSTNAME=${_HOSTNAME:-'gentoo-system-undefined'}
_USER=${_USER:-'user'}

get_smallest_device() { lsblk -bdno NAME,SIZE | awk '/^(sd|nvme)/ {print "/dev/"$1" "$2}' | sort -nk2 | head -n1 | cut -d' ' -f1; }
_DEV=${_DEV:-"$(get_smallest_device)"}

_BOOT_SIZE=${_BOOT_SIZE:-'1001MiB'} # 1gb
_SWAP_SIZE=${_SWAP_SIZE:-'5001MiB'} # 4gb
_ROOT_SIZE=${_ROOT_SIZE:-'100%'}    # remaining space

is_bios && _BOOT_FLAG='boot'
is_bios && _PART_TABLE='msdos'

is_uefi && _BOOT_FLAG='esp'
is_uefi && _PART_TABLE='gpt'

wipefs -a "$_DEV"*
parted -a optimal -s "$_DEV" \
  mklabel "$_PART_TABLE" \
  mkpart primary 1MiB "$_BOOT_SIZE" \
  set 1 "$_BOOT_FLAG" on name 1 _BOOT \
  mkpart primary "$_BOOT_SIZE" "$_SWAP_SIZE" \
  name 2 _SWAP \
  mkpart primary "$_SWAP_SIZE" "$_ROOT_SIZE" \
  name 3 _ROOT \
  print

get_partuuid() { blkid | grep "$(readlink -f "$1")" | grep -o 'PARTUUID="[^"]*"' | cut -d'"' -f2; }
_BOOT_DEV="/dev/disk/by-partuuid/$(get_partuuid /dev/disk/by-partlabel/_BOOT)"
_SWAP_DEV="/dev/disk/by-partuuid/$(get_partuuid /dev/disk/by-partlabel/_SWAP)"
_ROOT_DEV="/dev/disk/by-partuuid/$(get_partuuid /dev/disk/by-partlabel/_ROOT)"

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
