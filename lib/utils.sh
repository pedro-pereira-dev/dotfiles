#!/usr/bin/env bash
# shellcheck disable=SC2154

is_darwin() {
  grep -q darwinModules "$DOTS_ROOT/hosts/$1/default.nix"
}

select_host() {
  local host target
  host=$(get_parameter --host "$@") || true

  if [[ -z $host ]]; then
    target=$(get_parameter --target "$@") || true
    if get_parameter --self "$@" >/dev/null; then
      host=$(hostname)
    elif [[ -n $target ]]; then
      host=$(ssh "$target" hostname) || host=""
    fi
  fi

  if [[ ! -f $DOTS_ROOT/hosts/$host/default.nix ]]; then
    host=$(find "$DOTS_ROOT/hosts" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' |
      "${nix[@]}" run nixpkgs#fzf)
  fi

  if [[ ! -f $DOTS_ROOT/hosts/$host/default.nix ]]; then
    printf '%s - no configuration\n' "$host" >&2
    exit 1
  fi
  printf '%s\n' "$host"
}

select_target() {
  local self="" target=""
  if get_parameter --self "$@" >/dev/null; then self=1; fi
  if get_parameter --target "$@" >/dev/null; then
    target=$(get_parameter --target "$@")
    if [[ -z $target ]]; then exit 1; fi
  fi
  if [[ -z $self && -z $target || -n $self && -n $target ]]; then exit 1; fi
  printf '%s\n' "$target"
}
