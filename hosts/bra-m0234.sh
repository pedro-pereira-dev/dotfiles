#!/usr/bin/env bash

dots_pull() {
  install_xcode
  install_homebrew
  install_git
  maintain_dotfiles
}

dots_sync() {
  link_file "$DOTFILES_WORKSPACE/dots" "$HOME/.local/bin/dots"
  link_file "$DOTFILES_WORKSPACE/hosts/bra-m0234.d/brewfile" "$HOME/.Brewfile"
  link_file "$DOTFILES_WORKSPACE/bin/maintain-homebrew" "$HOME/.local/bin/maintain-homebrew"
  link_file "$DOTFILES_WORKSPACE/shared/bash_profile.sh" "$HOME/.bash_profile"
  link_file "$DOTFILES_WORKSPACE/shared/bashrc.sh" "$HOME/.bashrc"
  prune_stale_links
  "$HOME/.local/bin/maintain-homebrew" --force
}
