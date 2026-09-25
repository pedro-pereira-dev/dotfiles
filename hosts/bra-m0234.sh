#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

dots_pull() {
  source "$DOTFILES_WORKSPACE/scripts/install_xcode.sh"
  source "$DOTFILES_WORKSPACE/scripts/install_homebrew.sh"
  source "$DOTFILES_WORKSPACE/scripts/install_git.sh"
  maintain_dotfiles
}

dots_sync() {
  stow "$DOTFILES_WORKSPACE/dots" "$HOME/.local/bin/dots"
  stow "$DOTFILES_WORKSPACE/hosts/bra-m0234.d/brewfile" "$HOME/.Brewfile"
  stow "$DOTFILES_WORKSPACE/scripts/maintain_homebrew.sh" "$HOME/.local/bin/maintain-homebrew"
  stow "$DOTFILES_WORKSPACE/shared/bash_profile.sh" "$HOME/.bash_profile"
  stow "$DOTFILES_WORKSPACE/shared/bashrc.sh" "$HOME/.bashrc"
  stow "$DOTFILES_WORKSPACE/hosts/bra-m0234.d/tmp/temp1" "$HOME/.tmp-dotfiles/temp1"
  stow "$DOTFILES_WORKSPACE/hosts/bra-m0234.d/tmp/temp3" "$HOME/.tmp-dotfiles-moved/nested/temp3"
  stow "$DOTFILES_WORKSPACE/hosts/bra-m0234.d/tmp/temp4" "$HOME/.tmp-dotfiles/temp4"
  cleanup_stale_dotfiles
  "$HOME/.local/bin/maintain-homebrew" --force
}
