#!/usr/bin/env bash
# shellcheck disable=SC2024,SC2154

dots_bootstrap() {
  local -a sudo ssh_opts target_args
  local host target

  ssh_opts=(
    # prevents host key change errors
    -o StrictHostKeyChecking=no
    -o UserKnownHostsFile=/dev/null
  )

  target=$(select_target "$@")
  # kexec would kill this process, self only works from an installer
  if [[ -z $target ]] && ! grep -Eq 'VARIANT_ID="?installer"?' /etc/os-release; then
    printf '"bootstrap" --self requires a nixos installer, use --target from another machine\n'
    exit 1
  fi

  rm -f /tmp/key /tmp/key.pub
  ssh-keygen -q -t ed25519 -N "" -f /tmp/key

  if [[ -n $target ]]; then
    ssh -t "${ssh_opts[@]}" "$target" \
      "sudo sh -c 'install -d -m 700 /root/.ssh &&
      echo \"$(cat /tmp/key.pub)\" >>/root/.ssh/authorized_keys'"
  fi
  if [[ -z $target ]]; then
    sudo install -d -m 700 /root/.ssh
    sudo tee -a /root/.ssh/authorized_keys </tmp/key.pub >/dev/null
  fi

  host=$(get_parameter --host "$@") || true
  if [[ -z $host && -n $target ]]; then host=$(ssh "${ssh_opts[@]}" -i /tmp/key "root@${target#*@}" hostname) || true; fi
  host=$(select_host "$@" ${host:+--host "$host"})

  if is_nix_darwin "$host"; then
    printf '"install" is not supported on darwin\n'
    exit 1
  fi

  sudo=(sudo)
  target_args=(--target-host root@localhost -i /tmp/key)

  if [[ -n $target ]]; then
    sudo=()
    target_args=(--target-host "root@${target#*@}" --build-on remote -i /tmp/key)
  fi

  if [[ -n $target ]]; then
    # makes dhcp addresses static for kexec
    ssh "${ssh_opts[@]}" -i /tmp/key "root@${target#*@}" \
      'ip -o -4 addr show scope global dynamic | while read -r _ dev _ addr _; do
        ip addr change "$addr" dev "$dev" valid_lft forever preferred_lft forever
      done'
  fi

  "${sudo[@]}" "${nix[@]}" run \
    github:nix-community/nixos-anywhere -- \
    --generate-hardware-config nixos-generate-config "$DOTS_ROOT/hosts/$host.d/$host-hardware-configuration.nix" \
    --flake "path:$DOTS_ROOT#$host" \
    "${target_args[@]}"
}
