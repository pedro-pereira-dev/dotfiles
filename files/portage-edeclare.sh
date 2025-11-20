#!/bin/sh
# shellcheck disable=SC2046
set -eou pipefail

get_parameter() {
  _NAME='' && [ $# -ge 1 ] && _NAME=$1 && shift
  while [ $# -ge 1 ]; do
    _PARAM=$1 && shift
    if [ "$_NAME" = "$_PARAM" ]; then
      [ $# -ge 1 ] && _VAL=$1 && expr "x$_VAL" : 'x[^-]' >/dev/null && echo "$_VAL"
      return 0
    fi
  done
  return 1
}

is_root() { test "$(id -u)" -eq 0; }

run_as_root() { if is_root; then "$@"; elif command -v doas >/dev/null; then doas "$@"; elif command -v sudo >/dev/null; then sudo "$@"; fi; }

_DECLARED=$(mktemp) && sed -E -e '/^[[:space:]]*([#]|$)/d' -e 's/([[:space:]])+#.*$//' /etc/portage/package.declare | sort -u >"$_DECLARED"
_INSTALLED=$(mktemp) && sort -u /var/lib/portage/world >"$_INSTALLED"

_INSTALL=$(mktemp) && comm -23 "$_DECLARED" "$_INSTALLED" >"$_INSTALL"
_REMOVE=$(mktemp) && comm -23 "$_INSTALLED" "$_DECLARED" >"$_REMOVE"

get_parameter --unattended "$@" >/dev/null && _ASK=--ask=n || _ASK=--ask=y

[ -s "$_INSTALL" ] && run_as_root emerge -qv "$_ASK" $(paste -sd ' ' "$_INSTALL")
[ -s "$_REMOVE" ] && run_as_root emerge -Wqv "$_ASK" $(paste -sd ' ' "$_REMOVE")

rm -f "$_DECLARED" "$_INSTALL" "$_INSTALLED" "$_REMOVE"
