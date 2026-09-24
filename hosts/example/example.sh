#!/usr/bin/env bash

dots_pull() { log_info 'Using dotfiles from tarball for' "$(hostname -s)"; }

dots_sync() {
  stow "$DOTFILES_WORKSPACE/dots" "$HOME/.local/bin/dots"
  cleanup_stale_dotfiles
}
