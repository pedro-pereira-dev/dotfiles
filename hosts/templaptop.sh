#!/usr/bin/env bash

dots_pull() {
  maintain_dotfiles
}

dots_sync() {
  link_file "$DOTFILES_WORKSPACE/dots" "$HOME/.local/bin/dots"

  link_file "$DOTFILES_WORKSPACE/shared/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
  link_file "$DOTFILES_WORKSPACE/shared/bash_profile.sh" "$HOME/.bash_profile"
  link_file "$DOTFILES_WORKSPACE/shared/bashrc.sh" "$HOME/.bashrc"

  link_file "$DOTFILES_WORKSPACE/bin/update" "$HOME/.local/bin/update"

  prune_stale_links
  "$HOME/.local/bin/update" --force
}
