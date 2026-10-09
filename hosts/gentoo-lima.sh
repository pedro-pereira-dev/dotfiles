#!/usr/bin/env bash

dots_pull() {
  install_gentoo_git
  maintain_dotfiles
}

dots_sync() {
  link_file "$DOTFILES_WORKSPACE/dots" "$HOME/.local/bin/dots"

  link_file "$DOTFILES_WORKSPACE/shared/bashrc.sh" "$HOME/.bashrc"

  link_file "$DOTFILES_WORKSPACE/bin/update" "$HOME/.local/bin/update"

  prune_stale_links
  "$HOME/.local/bin/update" --force
}
