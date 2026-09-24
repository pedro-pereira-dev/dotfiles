#!/usr/bin/env bash

_stow_targets=()
_stow_changed=0

stow() {
  [[ $# -eq 2 && -f $1 && (! -d $2 || -L $2) ]] ||
    { log_fail 'Cannot symlink' "$1 -> $2" && return 1; }
  _stow_targets+=("$2")
  [[ -L $2 && $(readlink "$2") == "$1" ]] && return
  _stow_changed=1
  mkdir -p "$(dirname "$2")" || return
  rm -f "$2" || return
  log_check "Symlinking $2 to $1" ln -s "$1" "$2"
}
