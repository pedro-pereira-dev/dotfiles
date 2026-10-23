#!/usr/bin/env bash
# shellcheck disable=SC2024,SC2154

dots_bootstrap() {
  local host target
  local -a sudo target_args

  target=$(select_target "$@")
  host=$(select_host "$@")

  if is_darwin "$host"; then
    printf '"install" is not supported on darwin\n'
    exit 1
  fi

  if [[ -z $target ]]; then
    ssh-keygen -q -t ed25519 -N "" -f /tmp/key
    sudo install -d -m 700 /root/.ssh
    sudo tee -a /root/.ssh/authorized_keys </tmp/key.pub >/dev/null
  fi

  sudo=()
  target_args=(--target-host "$target" --build-on remote)

  if [[ -z $target ]]; then
    sudo=(sudo)
    target_args=(--target-host root@localhost -i /tmp/key)
  fi

  "${sudo[@]}" "${nix[@]}" run \
    github:nix-community/nixos-anywhere -- \
    --generate-hardware-config nixos-generate-config "$DOTS_ROOT/hosts/$host/hardware-configuration.nix" \
    --flake "path:$DOTS_ROOT#$host" \
    "${target_args[@]}"
}
