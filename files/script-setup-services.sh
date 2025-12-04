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

_declarations=$(mktemp)
[ $# -ge 1 ] && printf '%s\n' "$@" >>"$_declarations"
sed -E -e '/^[[:space:]]*([#]|$)/d' -e 's/([[:space:]])+#.*$//' \
  /etc/openrc/services.conf >>"$_declarations"

_declared=$(mktemp) && sort -u "$_declarations" >>"$_declared"
_enabled=$(mktemp) && rc-update show default | awk '{print $1}' | sort -u >"$_enabled"

_add=$(mktemp) && comm -23 "$_declared" "$_enabled" >"$_add"
_del=$(mktemp) && comm -23 "$_enabled" "$_declared" >"$_del"

[ -s "$_add" ] && cat "$_add" | run_as_root xargs -I {} rc-update add {}
[ -s "$_del" ] && cat "$_del" | run_as_root xargs -I {} rc-update del {}

rm -f "$_add" "$_declarations" "$_declared" "$_del" "$_enabled"
