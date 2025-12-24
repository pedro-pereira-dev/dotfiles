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

_declared=$(mktemp)
sed -E -e '/^[[:space:]]*([#]|$)/d' -e 's/([[:space:]])+#.*$//' \
  /etc/openrc/services.conf | sort -u >"$_declared"
_enabled=$(mktemp)
rc-update show default | awk '{print $1}' | sort -u >"$_enabled"

_add=$(mktemp)
comm -23 "$_declared" "$_enabled" >"$_add"
_delete=$(mktemp)
comm -23 "$_enabled" "$_declared" >"$_delete"

[ -s "$_add" ] &&
  cat "$_add" | run_as_root xargs -I {} rc-update add {} default
[ -s "$_delete" ] &&
  cat "$_delete" | run_as_root xargs -I {} rc-update del {} default

rm -f "$_add" "$_declared" "$_delete" "$_enabled"
