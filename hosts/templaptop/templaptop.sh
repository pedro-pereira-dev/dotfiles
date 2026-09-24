#!/usr/bin/env bash

dots_pull() { log_info 'Using dotfiles from tarball for' "$(hostname -s)"; }

dots_sync() {
  stow "$DOTFILES_WORKSPACE/dots" "$HOME/.local/bin/dots"
  stow "$DOTFILES_WORKSPACE/hosts/shared/bash_profile.sh" "$HOME/.bash_profile"
  stow "$DOTFILES_WORKSPACE/hosts/shared/bashrc.sh" "$HOME/.bashrc"
  cleanup_stale_dotfiles
}
