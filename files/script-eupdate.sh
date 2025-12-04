#!/bin/sh
set -eou pipefail

is_user() { _is_user_user=$1 && test "$(id -u)" -eq "$(id -u "$_is_user_user")"; }
is_root() { is_user root; }

run_as_root() {
  if is_root; then
    "$@"
  elif command -v doas >/dev/null; then
    doas "$@"
  elif command -v sudo >/dev/null; then
    sudo "$@"
  fi
}

[ ! -d /var/db/repos/gentoo/.git ] && run_as_root rm -fr /var/db/repos/gentoo
run_as_root emaint sync -A || true
