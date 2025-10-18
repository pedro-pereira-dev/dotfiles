#!/bin/sh

is_aarch64() { test "$(uname -m)" = 'aarch64'; }
is_amd64() { test "$(uname -m)" = 'x86_64'; }

is_bios() { ! is_uefi; }
is_uefi() { test -d '/sys/firmware/efi'; }

is_non_root() { ! is_root; }
is_root() { test "$(id -u)" -eq 0; }

if is_non_root; then
  doas "$0" "$@"
  exit $?
fi

# is_bios && _GRUB_CONFIG='/boot/grub/grub.cfg'
# is_uefi && is_aarch64 && _GRUB_CONFIG='/efi/EFI/gentoo/grubaa64.cfg'
# is_uefi && is_amd64 && _GRUB_CONFIG='/efi/EFI/gentoo/grub.cfg'

_GRUB_CONFIG='/boot/grub/grub.cfg'

dracut --force --hostonly --kver "$(eselect kernel list | grep --only-matching --perl-regexp 'linux-\K[^ ]+')" --quiet
grub-mkconfig --output="$_GRUB_CONFIG"
