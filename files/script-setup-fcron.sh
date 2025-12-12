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

_crontab=$(mktemp)
sed "s/__USER__/$1/g" /etc/fcron/crontab.sh >"$_crontab"

run_as_root fcrontab "$_crontab"
rm -f "$_crontab"
