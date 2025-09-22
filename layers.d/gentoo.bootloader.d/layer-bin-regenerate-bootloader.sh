#!/bin/bash
set -eo pipefail

if [[ ${EUID} -ne 0 ]]; then
  doas "$0" "$@"
  exit $?
fi

GRUB_CONFIG=$([ -d /sys/firmware/efi ] && echo '/efi/EFI/Gentoo/grub.cfg' || echo '/boot/grub/grub.cfg')

dracut --force --hostonly --kver "$(eselect kernel list | grep --only-matching --perl-regexp 'linux-\K[^ ]+')" --quiet
grub-mkconfig --output="${GRUB_CONFIG}"
