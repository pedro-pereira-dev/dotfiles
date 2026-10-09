#!/usr/bin/env bash
# shellcheck disable=SC2154
set -euo pipefail

dots_pull() {
  install_darwin_xcode
  install_darwin_homebrew
  install_darwin_git
  maintain_dotfiles
}

dots_sync() {

  link_file "$DOTFILES_WORKSPACE/bin/maintain-homebrew" "$HOME/.local/bin/maintain-homebrew"
  link_file "$DOTFILES_WORKSPACE/bin/maintain-macos" "$HOME/.local/bin/maintain-macos"
  link_file "$DOTFILES_WORKSPACE/bin/update" "$HOME/.local/bin/update"
  link_file "$DOTFILES_WORKSPACE/dots" "$HOME/.local/bin/dots"
  link_file "$DOTFILES_WORKSPACE/hosts/$_host.d/bordersrc" "$HOME/.config/borders/bordersrc"
  link_file "$DOTFILES_WORKSPACE/hosts/$_host.d/brewfile" "$HOME/.Brewfile"
  link_file "$DOTFILES_WORKSPACE/hosts/$_host.d/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
  link_file "$DOTFILES_WORKSPACE/hosts/$_host.d/sketchybar" "$HOME/.config/sketchybar"
  link_file "$DOTFILES_WORKSPACE/shared/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
  link_file "$DOTFILES_WORKSPACE/shared/bash_profile.sh" "$HOME/.bash_profile"
  link_file "$DOTFILES_WORKSPACE/shared/bashrc.sh" "$HOME/.bashrc"
  prune_stale_links

  "$HOME/.local/bin/update" --force

  install_darwin_bash
  set_darwin_bash_shell

  install_darwin_lima_vm
}
