#!/usr/bin/env bash
# shellcheck disable=SC1091

dots_pull() {
  source "$DOTFILES_WORKSPACE/hosts/bra-m0234/install_xcode.sh"
  source "$DOTFILES_WORKSPACE/hosts/bra-m0234/install_homebrew.sh"
  source "$DOTFILES_WORKSPACE/hosts/bra-m0234/install_git.sh"
  maintain_dotfiles
}

dots_sync() {
  stow "$DOTFILES_WORKSPACE/dots" "$HOME/.local/bin/dots"
  stow "$DOTFILES_WORKSPACE/hosts/bra-m0234/brewfile" "$HOME/.Brewfile"
  stow "$DOTFILES_WORKSPACE/hosts/shared/bash_profile.sh" "$HOME/.bash_profile"
  stow "$DOTFILES_WORKSPACE/hosts/shared/bashrc.sh" "$HOME/.bashrc"
  stow "$DOTFILES_WORKSPACE/hosts/bra-m0234/maintain_homebrew.sh" "$HOME/.local/bin/maintain-homebrew"
  cleanup_stale_dotfiles
  "$HOME/.local/bin/maintain-homebrew" --force
}
