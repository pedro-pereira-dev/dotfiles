#!/usr/bin/env bash
# shellcheck disable=SC2154

dots_setup() {
  local flake host target
  local -a nix_cmd sudo target_args

  target=$(select_target "$@")
  host=$(select_host "$@")

  if is_darwin "$host" && [[ -n $target ]]; then
    printf '"setup" --target is not supported on darwin\n'
    exit 1
  fi

  if [[ -f $DOTS_ROOT/hosts/$host/dots_setup.sh ]]; then
    source "$DOTS_ROOT/hosts/$host/dots_setup_$host.sh"
    "dots_setup_$host" "$@"
  fi

  flake="path:$DOTS_ROOT#$host"

  nix_cmd=(nixpkgs#nixos-rebuild)
  sudo=(sudo)
  target_args=()

  if is_darwin "$host"; then
    sudo=(sudo -H)
    nix_cmd=(nix-darwin)
  fi

  if [[ -n $target ]]; then
    sudo=()
    target_args=(--ask-sudo-password --build-host "$target" --sudo --target-host "$target")
  fi

  "${sudo[@]}" "${nix[@]}" run \
    "${nix_cmd[@]}" -- switch \
    --flake "$flake" \
    "${target_args[@]}"
}
