#!/bin/sh
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

_ask=--ask=y
[ $# -eq 1 ] && [ "$1" = --unattended ] && _ask=--ask=n

run_as_root emerge -DNquv $_ask --backtrack=30 --with-bdeps=y @world
exit 0
