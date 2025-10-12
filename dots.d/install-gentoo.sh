#!/bin/sh
set -eou pipefail

_GENTOO_RAW_URL='https://raw.githubusercontent.com/pedro-pereira-dev/gentoo-installer/refs/heads/main'

_BOOT_SIZE=${_BOOT_SIZE:-'1025MiB'} # 1gb
_SWAP_SIZE=${_SWAP_SIZE:-'5121MiB'} # 4gb
_ROOT_SIZE=${_ROOT_SIZE:-'100%'}    # remaining space

wipefs -a "$_DEV"*
if is_bios; then
  parted -a optimal -s "$_DEV" \
    mklabel msdos \
    mkpart primary 1MiB "$_BOOT_SIZE" \
    set 1 boot on name 1 _BOOT \
    mkpart primary "$_BOOT_SIZE" "$_SWAP_SIZE" \
    name 2 _SWAP \
    mkpart primary "$_SWAP_SIZE" "$_ROOT_SIZE" \
    name 3 _ROOT \
    print
  EOF
elif is_uefi; then
  parted -a optimal -s "$_DEV" \
    mklabel gpt \
    mkpart primary 1MiB "$_BOOT_SIZE" \
    set 1 esp on name 1 _BOOT \
    mkpart primary "$_BOOT_SIZE" "$_SWAP_SIZE" \
    name 2 _SWAP \
    mkpart primary "$_SWAP_SIZE" "$_ROOT_SIZE" \
    name 3 _ROOT \
    print
fi

curl -Lfs "$_GENTOO_RAW_URL/install.sh" | sh -s -- \
  --hostname "$_HOSTNAME" \
  --password "$_PASSWORD" \
  --boot '/dev/disk/by-partlabel/_BOOT' \
  --swap '/dev/disk/by-partlabel/_SWAP' \
  --root '/dev/disk/by-partlabel/_ROOT'

# # creates user account and sets up system using dotfiles
# chroot /mnt /bin/bash <<EOF
# env-update && source /etc/profile
# useradd -m -G wheel -s /bin/bash "$_USER"
# echo "$_USER:$_PASSWORD" | chpasswd
# emerge --ask=n --noreplace dev-vcs/git
# curl -Lfs "$_DOTS_RAW_URL/dots" | bash -s -- update
# /home/$_USER/$_DOTS_DIR/dots sync --full
# EOF
