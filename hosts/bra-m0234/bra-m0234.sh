#!/usr/bin/env bash
# shellcheck disable=SC1091
#
HOST_DIR="$DOTFILES_WORKSPACE/hosts/bra-m0234"

dots_pull() {
  source "$HOST_DIR/install_xcode.sh"
  source "$HOST_DIR/install_homebrew.sh"
  source "$HOST_DIR/install_git.sh"
}

dots_sync() {
  stow "$HOST_DIR/brewfile" "$HOME/.Brewfile"
  stow "$DOTFILES_WORKSPACE/hosts/shared/bash_profile.sh" "$HOME/.bash_profile"
  stow "$DOTFILES_WORKSPACE/hosts/shared/bashrc.sh" "$HOME/.bashrc"
}
