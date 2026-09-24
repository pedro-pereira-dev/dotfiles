#!/usr/bin/env bash

_find_dotfiles_symlinks() {
  find "$HOME" -xdev \
    \( -path "$DOTFILES_WORKSPACE" -o -name .git \) -prune -o \
    -type l -lname "$DOTFILES_WORKSPACE/*" -print 2>/dev/null || true
}

_remove_empty_parents() {
  local _dir=$1 && while
    [[ $_dir == "$HOME"/* ]] &&
      rmdir "$_dir" 2>/dev/null
  do _dir=$(dirname "$_dir"); done
}

cleanup_stale_dotfiles() {
  log_start 'Cleaning up' 'stale symlinks'
  local _link && while IFS= read -r _link; do
    log_check "Removing $_link" rm -f "$_link" || continue
    _remove_empty_parents "$(dirname "$_link")"
  done < <(_find_dotfiles_symlinks)
  log_ok
}
