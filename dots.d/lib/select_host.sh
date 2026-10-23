#!/usr/bin/env bash
# shellcheck disable=SC2154

select_host() {
  local host target
  if ! target=$(select_target "$@"); then return 1; fi
  host=$(get_parameter --host "$@") || true
  if [[ -z $host ]]; then
    host=$(hostname)
    if [[ -n $target ]]; then host=$(ssh "$target" hostname) || host=""; fi
  fi
  if [[ ! -f $DOTS_ROOT/hosts/$host.d/$host.nix ]]; then
  host=$(find "$DOTS_ROOT/hosts" -mindepth 1 -maxdepth 1 -type d -name '*.d' -printf '%f\n' |
      "${nix[@]}" run nixpkgs#fzf | sed 's/\.d$//')
  fi
  if [[ ! -f $DOTS_ROOT/hosts/$host.d/$host.nix ]]; then
    printf '%s - no dotfiles configuration\n' "$host"
    return 1
  fi
  printf '%s\n' "$host"
}
