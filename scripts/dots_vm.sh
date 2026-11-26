#!/usr/bin/env bash
# shellcheck disable=SC2154

dots_vm() {
  local host dir

  host=$(get_parameter --host "$@") || true

  if [[ -z $host ]]; then
    if ! host=$(find "$DOTS_ROOT/modules/hosts" -mindepth 1 -maxdepth 1 -type f -name '*.nix' -printf '%f\n' |
      sed 's/\.nix$//' |
      "${nix[@]}" run nixpkgs#fzf); then
      return 1
    fi
  fi

  if [[ ! -f $DOTS_ROOT/modules/hosts/$host.nix ]]; then
    printf '%s - no dotfiles configuration\n' "$host" >&2
    return 1
  fi

  if is_nix_darwin "$host"; then
    printf '"vm" is not supported on darwin\n' >&2
    return 1
  fi

  dir=/tmp/dots-vm/$host
  mkdir -p "$dir"

  "${nix[@]}" build \
    "path:$DOTS_ROOT#nixosConfigurations.$host.config.system.build.vm" \
    --out-link "$dir/result"

  # the VM writes its disk image to the current directory; running from $dir keeps it reusable
  cd "$dir" || exit
  "$dir/result/bin/run-$host-vm"
}
