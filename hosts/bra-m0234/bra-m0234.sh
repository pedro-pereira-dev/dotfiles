#!/usr/bin/env bash
# shellcheck disable=SC1091

HOST_DIR="$DOTFILES_WORKSPACE/hosts/bra-m0234"

_maitain_dotfiles() {
  source "$HOST_DIR/install_xcode.sh"
  source "$HOST_DIR/install_homebrew.sh"
  source "$HOST_DIR/install_git.sh"
  maintain_dotfiles
}

dots_pull() { _maitain_dotfiles; }

dots_sync() {
  _maitain_dotfiles
  stow "$HOST_DIR/brewfile" "$HOME/.Brewfile"
  stow "$DOTFILES_WORKSPACE/hosts/shared/bash_profile.sh" "$HOME/.bash_profile"
  stow "$DOTFILES_WORKSPACE/hosts/shared/bashrc.sh" "$HOME/.bashrc"
}
