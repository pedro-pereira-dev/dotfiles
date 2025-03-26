#!/bin/bash
set -eo pipefail

if [[ ${EUID} -ne 0 ]]; then
  su root -c "$0" "$@"
  exit $?
fi

function run_as_user() { if [[ ${EUID} -eq 0 ]]; then runuser --user="$1" -- "${@:2}"; else "${@:2}"; fi; }

SYSTEM_HOSTNAME='gentoo-router'
SYSTEM_USER='chuck'

DOTFILES_DIR="/home/${SYSTEM_USER}/workspace/personal/dotfiles"

find /etc /home /root /usr/bin -xtype l -delete >/dev/null 2>&1
find /etc /home /root /usr/bin -type d -empty >/dev/null 2>&1
bash ${DOTFILES_DIR}/shared/scripts/basic/stow ${DOTFILES_DIR}/shared/scripts/basic /usr/bin

stow ${DOTFILES_DIR}/${SYSTEM_HOSTNAME}/root /
stow ${DOTFILES_DIR}/ecare /usr/bin
stow ${DOTFILES_DIR}/shared/gentoo/esuite /usr/bin
stow ${DOTFILES_DIR}/shared/scripts/bootloader /usr/bin
stow ${DOTFILES_DIR}/shared/scripts/code /usr/bin
stow ${DOTFILES_DIR}/shared/scripts/secrets /usr/bin

run_as_user "${SYSTEM_USER}" stow ${DOTFILES_DIR}/${SYSTEM_HOSTNAME}/home /home/${SYSTEM_USER}
run_as_user "${SYSTEM_USER}" stow ${DOTFILES_DIR}/shared/bash /home/${SYSTEM_USER}
run_as_user "${SYSTEM_USER}" stow ${DOTFILES_DIR}/shared/git/configuration /home/${SYSTEM_USER}/.gitconfig
run_as_user "${SYSTEM_USER}" stow ${DOTFILES_DIR}/shared/git/partials /home/${SYSTEM_USER}/.config/git
run_as_user "${SYSTEM_USER}" stow ${DOTFILES_DIR}/shared/neovim /home/${SYSTEM_USER}/.config/nvim
run_as_user "${SYSTEM_USER}" stow ${DOTFILES_DIR}/shared/tmux /home/${SYSTEM_USER}/.config/tmux

if ! git -C /var/db/repos/gentoo status >/dev/null 2>&1; then
  rm --force --recursive /var/db/repos/gentoo
  eupdate
fi

eselect news read >/dev/null 2>&1
regenerate-bootloader
eauto --unsupervised

run_as_user "${SYSTEM_USER}" secrets-set gpg-github-pedro-pereira-dev
run_as_user "${SYSTEM_USER}" secrets-set ssh-github-pedro-pereira-dev
run_as_user "${SYSTEM_USER}" secrets-import
