#!/usr/bin/env bash

nix=(nix --extra-experimental-features "nix-command flakes")

dots_sync() {
  local host target
  host=$(get_parameter --host "$@") || true
  target=$(get_parameter --target "$@") || true
  if [[ -z $host && -n $target ]]; then host=$(ssh "$target" hostname -s); fi
  if [[ -z $host ]]; then host=$(hostname -s); fi
  is_host_configured "$host"
  local _flake="path:$DOTS_ROOT#$host"

  if is_darwin "$host"; then
    [[ -z $target ]] || { printf '%s - --target is not supported on darwin\n' "$host" >&2 && exit 1; }
    install_darwin_xcode
    install_darwin_homebrew
    install_nix
    sudo -H "${nix[@]}" run nix-darwin -- switch --flake "$_flake"
  elif [[ -n $target ]]; then
    "${nix[@]}" run nixpkgs#nixos-rebuild -- switch --flake "$_flake" \
      --target-host "$target" --build-host "$target" --sudo --ask-sudo-password
  else
    sudo "${nix[@]}" run nixpkgs#nixos-rebuild -- switch --flake "$_flake"
  fi
}
