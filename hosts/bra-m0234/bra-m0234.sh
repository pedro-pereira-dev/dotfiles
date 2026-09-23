#!/usr/bin/env bash

HOST_DIR='hosts/bra-m0234'

host_pull() {
  source_script "$HOST_DIR/install_xcode.sh"
  source_script "$HOST_DIR/install_homebrew.sh"
  source_script "$HOST_DIR/install_git.sh"
}

host_sync() {
  stow "$DOTFILES_WORKSPACE/$HOST_DIR/brewfile" "$HOME/.Brewfile"
  stow "$DOTFILES_WORKSPACE/hosts/shared/bash_profile.sh" "$HOME/.bash_profile"
  stow "$DOTFILES_WORKSPACE/hosts/shared/bashrc.sh" "$HOME/.bashrc"
}
