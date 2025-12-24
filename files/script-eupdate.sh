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

[ ! -d /var/db/repos/gentoo/.git ] &&
  run_as_root rm -fr /var/db/repos/gentoo

run_as_root emaint sync -A
exit 0
