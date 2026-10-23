#!/usr/bin/env bash
# shellcheck disable=SC2154

is_darwin() {
  grep -q darwinModules "$DOTS_ROOT/hosts/$1/default.nix"
}

select_host() {
  local host target
  if ! target=$(select_target "$@"); then return 1; fi
  host=$(get_parameter --host "$@") || true
  if [[ -z $host ]]; then
    host=$(hostname)
    if [[ -n $target ]]; then host=$(ssh "$target" hostname) || host=""; fi
  fi
  if [[ ! -f $DOTS_ROOT/hosts/$host/default.nix ]]; then
    host=$(find "$DOTS_ROOT/hosts" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' |
      "${nix[@]}" run nixpkgs#fzf)
  fi
  if [[ ! -f $DOTS_ROOT/hosts/$host/default.nix ]]; then
    printf '%s - no dotfiles configuration\n' "$host"
    return 1
  fi
  printf '%s\n' "$host"
}

select_target() {
  local self="" target=""
  if get_parameter --self "$@" >/dev/null; then self=1; fi
  if get_parameter --target "$@" >/dev/null; then
    target=$(get_parameter --target "$@")
    if [[ -z $target ]]; then
      printf '"--target" requires a host\n'
      return 1
    fi
  fi
  if [[ -z $self && -z $target || -n $self && -n $target ]]; then
    printf '"--self" and "--target" are exclusive\n'
    return 1
  fi
  printf '%s\n' "$target"
}
