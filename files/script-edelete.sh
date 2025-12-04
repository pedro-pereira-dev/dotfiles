#!/bin/sh
# shellcheck disable=SC2086
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

_ask=--ask=y && _opts=-A
[ $# -eq 1 ] && [ "$1" = --unattended ] && _ask=--ask=n && _opts=''

run_as_root emerge -cqv $_ask
command -v eclean-kernel >/dev/null && run_as_root eclean-kernel -n 1 -s mtime $_opts || true
