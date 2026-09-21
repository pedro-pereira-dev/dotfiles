#!/usr/bin/env bash
set -euo pipefail

HOST_DIR='hosts/bra-m0234'
log_info 'Executing dotfiles update for' 'bra-m0234'

source_script "$HOST_DIR/install_xcode.sh"
source_script "$HOST_DIR/install_homebrew.sh"
source_script "$HOST_DIR/install_git.sh"
clone_dotfiles

stow "$DOTFILES_WORKSPACE/$HOST_DIR/brewfile" "$HOME/.Brewfile"
stow "$DOTFILES_WORKSPACE/hosts/shared/bash_profile.sh" "$HOME/.bash_profile"
stow "$DOTFILES_WORKSPACE/hosts/shared/bashrc.sh" "$HOME/.bashrc"
