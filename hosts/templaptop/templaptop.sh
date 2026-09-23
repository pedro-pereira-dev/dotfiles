#!/usr/bin/env bash
# no git: files come from the bootstrap tarball, rerun bootstrap to update them

dots_pull() { log_info 'Using dotfiles from tarball for' 'templaptop'; }

dots_sync() {
  stow "$DOTFILES_WORKSPACE/hosts/shared/bash_profile.sh" "$HOME/.bash_profile"
  stow "$DOTFILES_WORKSPACE/hosts/shared/bashrc.sh" "$HOME/.bashrc"
}
