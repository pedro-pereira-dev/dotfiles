#!/bin/bash
set -eou pipefail

_HOME="$(get_home "$@")" && _USER="$(get_user "$@")"
_SCRIPT_DIR="$_HOME/$_DOTS_DIR/hosts.d/default.d"

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# symlinks dotfiles files to target system
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/dots" "$_HOME/.local/bin/dots"
run_as_user "$_USER" stow "$_SCRIPT_DIR/alacritty-config.toml" "$_HOME/.config/alacritty/alacritty.toml"
run_as_user "$_USER" stow "$_SCRIPT_DIR/bash-bashrc.sh" "$_HOME/.bashrc"
run_as_user "$_USER" stow "$_SCRIPT_DIR/bin-code.sh" "$_HOME/.local/bin/code"
run_as_user "$_USER" stow "$_SCRIPT_DIR/bin-install-nerd-font.sh" "$_HOME/.local/bin/install-nerd-font"
run_as_user "$_USER" stow "$_SCRIPT_DIR/bin-nvim-reloadable.sh" "$_HOME/.local/bin/nvim-reloadable"
run_as_user "$_USER" stow "$_SCRIPT_DIR/bin-secrets-bootstrap.sh" "$_HOME/.local/bin/secrets-bootstrap"
run_as_user "$_USER" stow "$_SCRIPT_DIR/bin-secrets-create.sh" "$_HOME/.local/bin/secrets-create"
run_as_user "$_USER" stow "$_SCRIPT_DIR/bin-secrets-import.sh" "$_HOME/.local/bin/secrets-import"
run_as_user "$_USER" stow "$_SCRIPT_DIR/bin-secrets-remove.sh" "$_HOME/.local/bin/secrets-remove"
run_as_user "$_USER" stow "$_SCRIPT_DIR/bin-secrets-set.sh" "$_HOME/.local/bin/secrets-set"
run_as_user "$_USER" stow "$_SCRIPT_DIR/git-config.conf" "$_HOME/.gitconfig"
run_as_user "$_USER" stow "$_SCRIPT_DIR/lazygit.config.yml" "$_HOME/.config/lazygit/config.yml"
run_as_user "$_USER" stow "$_SCRIPT_DIR/neovim-config.lua" "$_HOME/.config/nvim/init.lua"
run_as_user "$_USER" stow "$_SCRIPT_DIR/ssh-config.conf" "$_HOME/.ssh/config"
run_as_user "$_USER" stow "$_SCRIPT_DIR/ssh-github-pedro-pereira-dev.conf" "$_HOME/.ssh/config.d/github-pedro-pereira-dev.conf"
run_as_user "$_USER" stow "$_SCRIPT_DIR/ssh-mercedes-github-pesoare.conf" "$_HOME/.ssh/config.d/mercedes-github-pesoare.conf"
run_as_user "$_USER" stow "$_SCRIPT_DIR/tmux-config.conf" "$_HOME/.config/tmux/tmux.conf"
