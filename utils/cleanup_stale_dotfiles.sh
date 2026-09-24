#!/usr/bin/env bash
# shellcheck disable=SC2154

_find_dotfiles_symlinks() {
  find "$HOME" -xdev \
    \( -path "$DOTFILES_WORKSPACE" -o -name .git \) -prune -o \
    -type l -lname "$DOTFILES_WORKSPACE/*" -print 2>/dev/null || true
}

_is_stowed() {
  local _target && for _target in "${_stow_targets[@]}"; do
    [[ $1 == "$_target" ]] && return
  done
  return 1
}

_find_stale_symlinks() {
  local _link && while IFS= read -r _link; do
    [[ -e $_link ]] && _is_stowed "$_link" && continue
    printf '%s\n' "$_link"
  done < <(_find_dotfiles_symlinks)
}

_remove_empty_parents() {
  local _dir=$1 && while
    [[ $_dir == "$HOME"/* ]] &&
      rmdir "$_dir" 2>/dev/null
  do _dir=$(dirname "$_dir"); done
}

cleanup_stale_dotfiles() {
  ((_stow_changed || ${DOTFILES_UPDATED:-0})) || return 0
  local _stale && _stale=$(_find_stale_symlinks)
  [[ -n $_stale ]] || return 0
  log_start 'Cleaning up' 'stale symlinks'
  local _link && while IFS= read -r _link; do
    log_check "Removing $_link" rm -f "$_link" || continue
    _remove_empty_parents "$(dirname "$_link")"
  done <<<"$_stale"
  log_ok
}
