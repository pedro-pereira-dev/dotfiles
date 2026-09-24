#!/usr/bin/env bash
# shellcheck disable=SC1091

dots_pull() {
  source "$DOTFILES_WORKSPACE/hosts/templaptop/install_git.sh"
  maintain_dotfiles
}

dots_sync() {
  stow "$DOTFILES_WORKSPACE/dots" "$HOME/.local/bin/dots"
  stow "$DOTFILES_WORKSPACE/hosts/templaptop/aptfile" "$HOME/.Aptfile"
  stow "$DOTFILES_WORKSPACE/hosts/shared/bash_profile.sh" "$HOME/.bash_profile"
  stow "$DOTFILES_WORKSPACE/hosts/shared/bashrc.sh" "$HOME/.bashrc"
  stow "$DOTFILES_WORKSPACE/hosts/templaptop/maintain_apt.sh" "$HOME/.local/bin/maintain-apt"
  cleanup_stale_dotfiles
  "$HOME/.local/bin/maintain-apt" --force
}
