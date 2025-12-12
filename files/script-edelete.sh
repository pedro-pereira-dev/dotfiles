#!/bin/sh
# shellcheck disable=SC2086
set -eou pipefail

run_as_root() {
  if [ "$(id -u)" -eq "$(id -u root)" ]; then
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
command -v eclean-kernel >/dev/null &&
  run_as_root eclean-kernel -n 1 -s mtime $_opts
exit 0
