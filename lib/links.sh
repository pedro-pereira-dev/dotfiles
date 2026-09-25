#!/usr/bin/env bash

_linked_targets=()
_links_changed=0

link_file() {
  if [[ $# -ne 2 ]]; then return 1; fi

  local _source=$1 _target=$2
  if [[ ! -f $_source ]]; then return 1; fi
  if [[ -d $_target && ! -L $_target ]]; then return 1; fi

  _linked_targets+=("$_target")
  if [[ -L $_target && $(readlink "$_target") == "$_source" ]]; then return 0; fi

  _links_changed=1
  mkdir -p "$(dirname "$_target")"
  rm -fr "$_target"
  ln -fsv "$_source" "$_target"
}

_find_workspace_links() {
  find "$HOME" -xdev \
    \( -path "$DOTFILES_WORKSPACE" -o -name .git \) -prune -o \
    -type l -lname "$DOTFILES_WORKSPACE/*" -print 2>/dev/null || true
}

_is_linked() {
  local _target
  for _target in ${_linked_targets[@]+"${_linked_targets[@]}"}; do
    if [[ $1 == "$_target" ]]; then return 0; fi
  done
  return 1
}

_remove_empty_parents() {
  local _dir=$1
  while [[ $_dir == "$HOME"/* ]] && rmdir "$_dir" 2>/dev/null; do
    _dir=$(dirname "$_dir")
  done
}

prune_stale_links() {
  if ((! _links_changed && ! ${DOTFILES_UPDATED:-0})); then return 0; fi
  local _link
  while IFS= read -r _link; do
    if [[ -e $_link ]] && _is_linked "$_link"; then continue; fi
    rm -frv "$_link"
    _remove_empty_parents "$(dirname "$_link")"
  done < <(_find_workspace_links)
}
