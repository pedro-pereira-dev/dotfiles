#!/usr/bin/env bash
# shellcheck disable=SC2154

select_host() {
  local host target

  if ! target=$(select_target "$@"); then return 1; fi
  host=$(get_parameter --host "$@") || true

  if [[ -z $host ]]; then
    if [[ -z $target ]]; then host=$(hostname); fi
    if [[ -n $target ]]; then host=$(ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$target" hostname) || host=""; fi
  fi

  if [[ ! -f $DOTS_ROOT/hosts/$host.d/$host.nix ]]; then
    if ! host=$(find "$DOTS_ROOT/hosts" -mindepth 1 -maxdepth 1 -type d -name '*.d' -printf '%f\n' | sed 's/\.d$//' | "${nix[@]}" run nixpkgs#fzf); then
      return 1
    fi
  fi

  if [[ ! -f $DOTS_ROOT/hosts/$host.d/$host.nix ]]; then
    printf '%s - no dotfiles configuration\n' "$host"
    return 1
  fi

  printf '%s\n' "$host"
}
