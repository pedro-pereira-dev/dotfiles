#!/usr/bin/env bash
# shellcheck disable=SC2024,SC2154

host=$(get_parameter --host "$@") || true
self=$(get_parameter --self "$@" >/dev/null && echo 1) || true
target=$(get_parameter --target "$@") || true

if [[ -z $self && -z $target || -n $self && -n $target ]]; then exit 1; fi
if [[ -z $host ]]; then host=$(find "$DOTS_ROOT/hosts" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | "${nix[@]}" run nixpkgs#fzf); fi

is_host_configured "$host"
if is_darwin "$host"; then printf '"install" is not supported on darwin\n' >&2 && exit 1; fi

sudo=()
target_args=(--target-host "$target" --build-on remote)
if [[ -z $target ]]; then
  sudo=(sudo)
  target_args=(--target-host root@localhost -i /tmp/key)
  ssh-keygen -q -t ed25519 -N "" -f /tmp/key
  sudo install -d -m 700 /root/.ssh
  sudo tee -a /root/.ssh/authorized_keys </tmp/key.pub >/dev/null
fi

"${sudo[@]}" "${nix[@]}" run github:nix-community/nixos-anywhere -- \
  --generate-hardware-config nixos-generate-config "$DOTS_ROOT/hosts/$host/hardware-configuration.nix" \
  --flake "path:$DOTS_ROOT#$host" \
  "${target_args[@]}"
