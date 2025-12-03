#!/bin/sh
# shellcheck disable=SC2046
set -eou pipefail

is_root() { test "$(id -u)" -eq "$(id -u root)"; }
run_as_root() { if is_root; then "$@"; elif command -v doas >/dev/null; then doas "$@"; elif command -v sudo >/dev/null; then sudo "$@"; fi; }

_DECLARED=$(mktemp) && sed -E -e '/^[[:space:]]*([#]|$)/d' -e 's/([[:space:]])+#.*$//' /etc/portage/package.declare | sort -u >"$_DECLARED"
_INSTALLED=$(mktemp) && sort -u /var/lib/portage/world >"$_INSTALLED"

_INSTALL=$(mktemp) && comm -23 "$_DECLARED" "$_INSTALLED" >"$_INSTALL"
_REMOVE=$(mktemp) && comm -23 "$_INSTALLED" "$_DECLARED" >"$_REMOVE"

_ASK=--ask=y && [ $# -eq 1 ] && [ "$1" = --unattended ] && _ASK=--ask=n
[ -s "$_INSTALL" ] && run_as_root emerge -qv $_ASK $(paste -sd ' ' "$_INSTALL")
[ -s "$_REMOVE" ] && run_as_root emerge -Wqv $_ASK $(paste -sd ' ' "$_REMOVE")

rm -f "$_DECLARED" "$_INSTALL" "$_INSTALLED" "$_REMOVE"
