#!/bin/bash
set -eo pipefail

if [[ ${EUID} -ne 0 ]]; then
  doas "$0" "$@"
  exit $?
fi

function run_as_user() { if [[ ${EUID} -eq 0 ]]; then su "$1" -c "${*:2}"; else "${@:2}"; fi; }
function ustow() { run_as_user chuck stow "$@"; }

/home/chuck/workspace/personal/dotfiles/shared/scripts/utils.stow /home/chuck/workspace/personal/dotfiles/shared/scripts/utils.stow /usr/bin/stow

stow /home/chuck/workspace/personal/dotfiles/gentoo-laptop-dell/portage /etc/portage
stow /home/chuck/workspace/personal/dotfiles/shared/configurations/gentoo.dracut-i915 /etc/dracut.conf.d/i915.conf
# stow /home/chuck/workspace/personal/dotfiles/shared/configurations/gentoo.gentoobinhost-ulisboa.conf /etc/portage/binrepos.conf/gentoobinhost-ulisboa.conf
# stow /home/chuck/workspace/personal/dotfiles/shared/configurations/gentoo.grub /etc/default/grub
stow /home/chuck/workspace/personal/dotfiles/shared/configurations/gentoo.inittab /etc/inittab
stow /home/chuck/workspace/personal/dotfiles/shared/configurations/gentoo.overlay-gentoo.conf /etc/portage/repos.conf/overlay-gentoo.conf
stow /home/chuck/workspace/personal/dotfiles/shared/configurations/gentoo.overlay-guru.conf /etc/portage/repos.conf/overlay-guru.conf
stow /home/chuck/workspace/personal/dotfiles/shared/scripts/code.nvim-reloadable /usr/bin/nvim-reloadable
stow /home/chuck/workspace/personal/dotfiles/shared/scripts/code.sessionizer /usr/bin/code
stow /home/chuck/workspace/personal/dotfiles/shared/scripts/gentoo.backlight-down /usr/bin/backlight-down
stow /home/chuck/workspace/personal/dotfiles/shared/scripts/gentoo.backlight-up /usr/bin/backlight-up
stow /home/chuck/workspace/personal/dotfiles/shared/scripts/gentoo.eauto /usr/bin/eauto
stow /home/chuck/workspace/personal/dotfiles/shared/scripts/gentoo.edeclare /usr/bin/edeclare
stow /home/chuck/workspace/personal/dotfiles/shared/scripts/gentoo.edelete /usr/bin/edelete
stow /home/chuck/workspace/personal/dotfiles/shared/scripts/gentoo.eupdate /usr/bin/eupdate
stow /home/chuck/workspace/personal/dotfiles/shared/scripts/gentoo.eupgrade /usr/bin/eupgrade
stow /home/chuck/workspace/personal/dotfiles/shared/scripts/gentoo.pipewire-microphone-toggle /usr/bin/pipewire-microphone-toggle
stow /home/chuck/workspace/personal/dotfiles/shared/scripts/gentoo.pipewire-volume-down /usr/bin/pipewire-volume-down
stow /home/chuck/workspace/personal/dotfiles/shared/scripts/gentoo.pipewire-volume-toggle /usr/bin/pipewire-volume-toggle
stow /home/chuck/workspace/personal/dotfiles/shared/scripts/gentoo.pipewire-volume-up /usr/bin/pipewire-volume-up
stow /home/chuck/workspace/personal/dotfiles/shared/scripts/gentoo.regenerate-bootloader /usr/bin/regenerate-bootloader
stow /home/chuck/workspace/personal/dotfiles/shared/scripts/secrets.secrets-bootstrap /usr/bin/secrets-bootstrap
stow /home/chuck/workspace/personal/dotfiles/shared/scripts/secrets.secrets-create /usr/bin/secrets-create
stow /home/chuck/workspace/personal/dotfiles/shared/scripts/secrets.secrets-import /usr/bin/secrets-import
stow /home/chuck/workspace/personal/dotfiles/shared/scripts/secrets.secrets-remove /usr/bin/secrets-remove
stow /home/chuck/workspace/personal/dotfiles/shared/scripts/secrets.secrets-set /usr/bin/secrets-set
stow /home/chuck/workspace/personal/dotfiles/shared/scripts/utils.bootstrap-dotfiles /usr/bin/bootstrap-dotfiles
stow /home/chuck/workspace/personal/dotfiles/shared/scripts/utils.install-nerd-font /usr/bin/install-nerd-font

stow /home/chuck/workspace/personal/dotfiles/dots /usr/bin/
stow /home/chuck/workspace/personal/dotfiles/dots-utils /usr/bin/

ustow /home/chuck/workspace/personal/dotfiles/shared/configurations/bash.bash-display /home/chuck/.bash_display
ustow /home/chuck/workspace/personal/dotfiles/shared/configurations/bash.bash-profile /home/chuck/.bash_profile
ustow /home/chuck/workspace/personal/dotfiles/shared/configurations/bash.bashrc /home/chuck/.bashrc
ustow /home/chuck/workspace/personal/dotfiles/shared/configurations/git.gitconfig /home/chuck/.gitconfig
ustow /home/chuck/workspace/personal/dotfiles/shared/configurations/git.github-pedro-pereira-dev /home/chuck/.config/git/github-pedro-pereira-dev
ustow /home/chuck/workspace/personal/dotfiles/shared/configurations/git.lazygit.yml /home/chuck/.config/lazygit/config.yml
ustow /home/chuck/workspace/personal/dotfiles/shared/configurations/neovim.init.lua /home/chuck/.config/nvim/init.lua
ustow /home/chuck/workspace/personal/dotfiles/shared/configurations/ssh.config /home/chuck/.ssh/config
ustow /home/chuck/workspace/personal/dotfiles/shared/configurations/ssh.github-pedro-pereira-dev /home/chuck/.ssh/config.d/github-pedro-pereira-dev
ustow /home/chuck/workspace/personal/dotfiles/shared/configurations/ssh.mercedes-github-pesoare /home/chuck/.ssh/config.d/mercedes-github-pesoare
ustow /home/chuck/workspace/personal/dotfiles/shared/configurations/ssh.ssh-gentoo-laptop /home/chuck/.ssh/config.d/zz-default
ustow /home/chuck/workspace/personal/dotfiles/shared/configurations/sway.config /home/chuck/.config/sway/config
ustow /home/chuck/workspace/personal/dotfiles/shared/configurations/system.dark-theme /home/chuck/.config/gtk-3.0/settings.ini
ustow /home/chuck/workspace/personal/dotfiles/shared/configurations/system.dark-theme /home/chuck/.config/gtk-4.0/settings.ini
ustow /home/chuck/workspace/personal/dotfiles/shared/configurations/terminal.alacritty.toml /home/chuck/.config/alacritty/alacritty.toml
ustow /home/chuck/workspace/personal/dotfiles/shared/configurations/tmux.tmux.conf /home/chuck/.config/tmux/tmux.conf

find /etc /home /root /usr/bin -xtype l -delete >/dev/null 2>&1
find /etc /home /root /usr/bin -type d -empty >/dev/null 2>&1

[[ ! -d /var/db/repos/gentoo/.git ]] && rm --force --recursive /var/db/repos/gentoo
#eauto --unsupervised
eselect news read >/dev/null 2>&1
#regenerate-bootloader

cat <<EOF >/etc/doas.conf
permit persist :wheel
permit nopass :wheel as root cmd reboot
permit nopass :wheel as root cmd shutdown
EOF
chown --changes root:root /etc/doas.conf
chmod --changes 0400 /etc/doas.conf
passwd --delete --lock root >/dev/null 2>&1

[[ -z $(eselect editor list | grep --perl-regexp "$(which nvim) \*$") ]] && eselect editor set "$(which nvim)"
rc-update add NetworkManager default >/dev/null 2>&1
rc-update add power-profiles-daemon default >/dev/null 2>&1
usermod --append --groups video chuck # for backlight

run_as_user chuck install-nerd-font JetBrainsMono

run_as_user chuck secrets-set gpg-github-pedro-pereira-dev
run_as_user chuck secrets-set ssh-authorized-keys
run_as_user chuck secrets-set ssh-gentoo-hetzner-media
run_as_user chuck secrets-set ssh-gentoo-laptop
run_as_user chuck secrets-set ssh-github-pedro-pereira-dev
run_as_user chuck secrets-set ssh-mercedes-github-pesoare
run_as_user chuck secrets-import
rm --force /home/chuck/.ssh/authorized_keys
