#!/bin/sh
# shellcheck disable=SC2046
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
sed -E -e '/^[[:space:]]*([#]|$)/d' -e 's/([[:space:]])+#.*$//' /etc/portage/package.declare | sort -u >"$_declared"
_installed=$(mktemp)
sort -u /var/lib/portage/world >"$_installed"

_install=$(mktemp)
comm -23 "$_declared" "$_installed" >"$_install"
_remove=$(mktemp)
comm -23 "$_installed" "$_declared" >"$_remove"

_ask=--ask=y
[ $# -eq 1 ] && [ "$1" = --unattended ] && _ask=--ask=n

[ -s "$_install" ] &&
  run_as_root emerge -qv $_ask $(paste -sd ' ' "$_install")
[ -s "$_remove" ] &&
  run_as_root emerge -Wqv $_ask $(paste -sd ' ' "$_remove")

rm -f "$_declared" "$_install" "$_installed" "$_remove"
