#!/usr/bin/env bash
# shellcheck disable=SC2154

dots_setup() {
  local -a nix_cmd ssh_opts sudo target_args
  local flake host target

  ssh_opts=(
    # reuses ssh connection
    -o ControlMaster=auto
    -o ControlPath=/tmp/dots-ssh-%C
    # sets connection time to live
    -o ControlPersist=60
    # prevents host key change errors
    -o StrictHostKeyChecking=no
    -o UserKnownHostsFile=/dev/null
  )

  # shares ssh options with nix
  local NIX_SSHOPTS="${ssh_opts[*]}${NIX_SSHOPTS:+ $NIX_SSHOPTS}"
  export NIX_SSHOPTS

  target=$(select_target "$@")
  # starts ssh connection so ssh password prompt only happens here
  if [[ -n $target ]] && ! ssh "${ssh_opts[@]}" "$target" true; then exit 1; fi

  host=$(get_parameter --host "$@") || true
  if [[ -z $host && -n $target ]]; then host=$(ssh "${ssh_opts[@]}" "$target" hostname) || true; fi
  host=$(select_host "$@" ${host:+--host "$host"})

  if is_nix_darwin "$host" && [[ -n $target ]]; then
    printf '"setup" --target is not supported on darwin\n'
    exit 1
  fi

  if [[ -f $DOTS_ROOT/hosts/$host.d/dots_setup.sh ]]; then
    source "$DOTS_ROOT/hosts/$host.d/dots_setup.sh"
    "dots_setup_$host" "$@"
  fi

  flake="path:$DOTS_ROOT#$host"

  nix_cmd=(nixpkgs#nixos-rebuild)
  sudo=(sudo)
  target_args=()

  if is_nix_darwin "$host"; then
    sudo=(sudo -H)
    nix_cmd=(nix-darwin)
  fi

  if [[ -n $target ]]; then
    sudo=()
    target_args=(--build-host "$target" --target-host "$target")
    if [[ $target != root@* ]]; then target_args+=(--ask-sudo-password --sudo); fi
  fi

  "${sudo[@]}" "${nix[@]}" run \
    "${nix_cmd[@]}" -- switch \
    --flake "$flake" \
    "${target_args[@]}"
}
