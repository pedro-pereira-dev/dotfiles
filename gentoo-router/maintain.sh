#!/bin/bash

SYSTEM_HOSTNAME='gentoo-router'
SYSTEM_USER='chuck'

DOTFILES_DIR="/home/${SYSTEM_USER}/workspace/personal/dotfiles"
SHARED_DIR="${DOTFILES_DIR}/shared"
SYSTEM_DIR="${DOTFILES_DIR}/${SYSTEM_HOSTNAME}"

[[ ${EUID} -ne 0 ]] && ! command -v doas >/dev/null 2>&1 && echo -e 'Aborting... this should not have happened!\nRun as root at least once.' && return 1

function is_root() { [[ ${EUID} -eq 0 ]] && return 0 || return 1; }
function run_as_root() { if [[ ${EUID} -eq 0 ]]; then "${@:2}"; else "${@:1}"; fi; }
function run_as_user() { if [[ ${EUID} -eq 0 ]]; then runuser -u "$1" -- "${@:2}"; else "${@:2}"; fi; }

run_as_root doas find /etc /home /root /usr/bin -xtype l -delete
run_as_root doas find /etc /home /root /usr/bin -type d -empty
run_as_root doas bash ${SHARED_DIR}/scripts/stow/stow ${SHARED_DIR}/scripts/stow /usr/bin

run_as_root doas stow ${DOTFILES_DIR}/ecare /usr/bin
run_as_root doas stow ${SHARED_DIR}/gentoo/esuite /usr/bin
run_as_root doas stow ${SHARED_DIR}/scripts/secrets /usr/bin
run_as_root doas stow ${SYSTEM_DIR}/root /

if ! run_as_root doas git -C /var/db/repos/gentoo status >/dev/null 2>&1; then
  run_as_root doas rm -rf /var/db/repos/gentoo
  run_as_root doas eupdate
fi

if is_root; then
  eselect news read >/dev/null 2>&1
  command -v dracut >/dev/null 2>&1 && dracut --force --hostonly --quiet --kver "$(eselect kernel list | grep -oP 'linux-\K[^ ]+')"
  command -v grub-mkconfig >/dev/null 2>&1 && grub-mkconfig -o /boot/grub/grub.cfg
fi

run_as_root doas eauto "$([[ ${EUID} -eq 0 ]] && echo '--unsupervised' || echo '')"
run_as_user "${SYSTEM_USER}" secsetup github
run_as_user "${SYSTEM_USER}" secimport
