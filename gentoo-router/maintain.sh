#!/bin/bash
set -eo pipefail

[[ ${EUID} -ne 0 ]] && doas "$0" "$@" && exit $?

function run_as_user() { if [[ ${EUID} -eq 0 ]]; then su "$1" -c "${*:2}"; else "${@:2}"; fi; }
function ustow() { run_as_user chuck stow "$@"; }

/home/chuck/workspace/personal/dotfiles/shared/scripts/basic/stow /home/chuck/workspace/personal/dotfiles/shared/scripts/basic/stow /usr/bin

stow /home/chuck/workspace/personal/dotfiles/gentoo-router/portage /etc/portage
stow /home/chuck/workspace/personal/dotfiles/shared/doas /etc
stow /home/chuck/workspace/personal/dotfiles/shared/dotfiles-installer/bootstrap-dotfiles /usr/bin
stow /home/chuck/workspace/personal/dotfiles/shared/gentoo/esuite /usr/bin
stow /home/chuck/workspace/personal/dotfiles/shared/gentoo/overlays/gentoo.conf /etc/portage/repos.conf/gentoo.conf
stow /home/chuck/workspace/personal/dotfiles/shared/gentoo/overlays/overlay-guru.conf /etc/portage/repos.conf/overlay-guru.conf
stow /home/chuck/workspace/personal/dotfiles/shared/scripts/basic /usr/bin
stow /home/chuck/workspace/personal/dotfiles/shared/scripts/code /usr/bin
stow /home/chuck/workspace/personal/dotfiles/shared/scripts/secrets /usr/bin

ustow /home/chuck/workspace/personal/dotfiles/shared/bash /home/chuck
ustow /home/chuck/workspace/personal/dotfiles/shared/git/configuration /home/chuck/.gitconfig
ustow /home/chuck/workspace/personal/dotfiles/shared/git/partials /home/chuck/.config/git
ustow /home/chuck/workspace/personal/dotfiles/shared/neovim /home/chuck/.config/nvim
ustow /home/chuck/workspace/personal/dotfiles/shared/ssh/configuration /home/chuck/.ssh/config
ustow /home/chuck/workspace/personal/dotfiles/shared/ssh/partials/github-pedro-pereira-dev /home/chuck/.ssh/partials/github-pedro-pereira-dev
ustow /home/chuck/workspace/personal/dotfiles/shared/tmux /home/chuck/.config/tmux

[[ ! -d /var/db/repos/gentoo/.git ]] && rm --force --recursive /var/db/repos/gentoo
eauto --unsupervised
eselect news read >/dev/null 2>&1
regenerate-bootloader

run_as_user chuck secrets-set gpg-github-pedro-pereira-dev
run_as_user chuck secrets-set ssh-github-pedro-pereira-dev
run_as_user chuck secrets-import

find /etc /home /root /usr/bin -xtype l -delete >/dev/null 2>&1
find /etc /home /root /usr/bin -type d -empty >/dev/null 2>&1
