#!/bin/sh
# shellcheck disable=SC2015 source=/dev/null
set -eou pipefail

is_bios() { ! is_uefi; }
is_uefi() { test -d /sys/firmware/efi; }

get_parameter() {
  _FLAG=$1 && shift && while [ $# -ge 1 ]; do
    _PARAM=$1 && shift && [ "$_FLAG" = "$_PARAM" ] && {
      _VAL='' && [ $# -ge 1 ] && _VAL=$1
      [ -n "$_VAL" ] && expr "x$_VAL" : 'x[^-]' >/dev/null && echo "$_VAL" || true # prints out if not starting by -
    } && return 0
  done && return 1
}

_HOSTNAME=$(get_parameter --hostname "$@") && [ -n "$_HOSTNAME" ] ||
  { echo '[E] missing required argument --hostname' && exit 1; }
_PASSWORD=$(get_parameter --password "$@") && [ -n "$_PASSWORD" ] ||
  { echo '[E] missing required argument --password' && exit 1; }

# sources host configuration from dotfiles github repository
_URL=https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/hosts/$_HOSTNAME/$_HOSTNAME.sh
curl -ILfs "$_URL" >/dev/null && _TMP=$(mktemp) && curl -Lfs "$_URL" -o "$_TMP" && . "$_TMP" ||
  { echo "[E] failed to source $_URL" && exit 1; }

_USER=${_USER:-user}

_BOOT_SIZE=${_BOOT_SIZE:-+512M}
_ROOT_SIZE=${_ROOT_SIZE:-' '}
_SWAP_SIZE=${_SWAP_SIZE:-1G}

_SMALLEST_DISK=$(lsblk -bdno NAME,SIZE,TYPE | grep disk | sort -nk2 | head -n1 | cut -d' ' -f1)
_DISK=${_DISK:-"/dev/$_SMALLEST_DISK"}

# removes all partitions and mapped devices
wipefs -a "$_DISK"* && find /dev/disk -type l -exec sh -c '[ ! -e "$1" ] && rm -f "$1" >/dev/null 2>&1' _ {} \;

is_bios && _DISK_LAYOUT="0,n, , , ,$_BOOT_SIZE,a,n, , , ,$_ROOT_SIZE,p,w"
is_uefi && _DISK_LAYOUT="g,n, , ,$_BOOT_SIZE,Y,t,1,n, , ,$_ROOT_SIZE,Y,p,w"
printf '%s' "$_DISK_LAYOUT" | tr , '\n' | fdisk "$_DISK"

get_device_partition() { _DEV=$1 && _PART=$2 && lsblk -f "$_DEV" -nro NAME,TYPE | grep -E ".*$_PART " | cut -d' ' -f1; }

_BOOT_DEV=/dev/$(get_device_partition "$_DISK" 1)
_ROOT_DEV=/dev/$(get_device_partition "$_DISK" 2)

curl -Lfs https://raw.githubusercontent.com/pedro-pereira-dev/gentoo-installer/refs/heads/main/install.sh -o /tmp/install.sh
yes | sh /tmp/install.sh \
  --hostname "$_HOSTNAME" \
  --password "$_PASSWORD" \
  --boot "$_BOOT_DEV" \
  --root "$_ROOT_DEV" \
  --swap "$_SWAP_SIZE" \
  --keymap pt-latin9 \
  --timezone Europe/Lisbon || true

chroot /mnt /bin/bash <<EOF
env-update && source /etc/profile

useradd -G wheel -ms /usr/bin/bash $_USER
echo $_USER:$_PASSWORD | chpasswd

emerge --ask=n -1n dev-vcs/git
curl -Lfs https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/dots.sh -o /tmp/dots.sh 
sh /tmp/dots.sh sync --full --hostname $_HOSTNAME --user $_USER

/usr/bin/installkernel -a
/usr/bin/edelete --unattended
EOF
