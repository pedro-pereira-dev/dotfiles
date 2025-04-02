#!/bin/bash
set -eo pipefail

[[ ${EUID} -ne 0 ]] && su root -c "$0" "$@" && exit $?

function run_as_user() { if [[ ${EUID} -eq 0 ]]; then runuser --user="$1" -- "${@:2}"; else "${@:2}"; fi; }
function ustow() { run_as_user "${SYSTEM_USER}" stow "$@"; }

SYSTEM_HOSTNAME='gentoo-router'
SYSTEM_USER='chuck'

DOTFILES_DIR="/home/${SYSTEM_USER}/workspace/personal/dotfiles"

find /etc /home /root /usr/bin -xtype l -delete >/dev/null 2>&1
find /etc /home /root /usr/bin -type d -empty >/dev/null 2>&1
bash ${DOTFILES_DIR}/shared/scripts/basic/stow ${DOTFILES_DIR}/shared/scripts/basic/stow /usr/bin

stow ${DOTFILES_DIR}/${SYSTEM_HOSTNAME}/portage /etc/portage
stow ${DOTFILES_DIR}/ecare /usr/bin
stow ${DOTFILES_DIR}/shared/gentoo/esuite /usr/bin
stow ${DOTFILES_DIR}/shared/gentoo/overlays/gentoo.conf /etc/portage/repos.conf
stow ${DOTFILES_DIR}/shared/gentoo/overlays/overlay-guru.conf /etc/portage/repos.conf
stow ${DOTFILES_DIR}/shared/scripts/basic /usr/bin
stow ${DOTFILES_DIR}/shared/scripts/code /usr/bin
stow ${DOTFILES_DIR}/shared/scripts/secrets /usr/bin

ustow ${DOTFILES_DIR}/shared/bash /home/${SYSTEM_USER}
ustow ${DOTFILES_DIR}/shared/git/configuration /home/${SYSTEM_USER}/.gitconfig
ustow ${DOTFILES_DIR}/shared/git/partials /home/${SYSTEM_USER}/.config/git
ustow ${DOTFILES_DIR}/shared/neovim /home/${SYSTEM_USER}/.config/nvim
ustow ${DOTFILES_DIR}/shared/ssh/configuration /home/${SYSTEM_USER}/.ssh/config
ustow ${DOTFILES_DIR}/shared/ssh/partials/github-pedro-pereira-dev /home/${SYSTEM_USER}/.ssh/partials/github-pedro-pereira-dev
ustow ${DOTFILES_DIR}/shared/tmux /home/${SYSTEM_USER}/.config/tmux

[[ ! -d /var/db/repos/gentoo/.git ]] && rm --force --recursive /var/db/repos/gentoo && eupdate
eauto --unsupervised
eselect news read >/dev/null 2>&1
regenerate-bootloader

run_as_user "${SYSTEM_USER}" secrets-set gpg-github-pedro-pereira-dev
run_as_user "${SYSTEM_USER}" secrets-set ssh-github-pedro-pereira-dev
run_as_user "${SYSTEM_USER}" secrets-import
