#!/usr/bin/env bash
set -euo pipefail

_stow_targets=()
_stow_changed=0

stow() {
  [[ $# -eq 2 && -f $1 && (! -d $2 || -L $2) ]] ||
    { printf 'stow: cannot symlink %s -> %s\n' "$1" "$2" >&2 && return 1; }
  _stow_targets+=("$2")
  [[ -L $2 && $(readlink "$2") == "$1" ]] && return
  _stow_changed=1
  mkdir -p "$(dirname "$2")"
  rm -fr "$2" || return
  ln -fsv "$1" "$2"
}
