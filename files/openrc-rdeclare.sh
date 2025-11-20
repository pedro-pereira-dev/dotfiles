#!/bin/sh
set -eou pipefail

is_root() { test "$(id -u)" -eq 0; }

run_as_root() { if is_root; then "$@"; elif command -v doas >/dev/null; then doas "$@"; elif command -v sudo >/dev/null; then sudo "$@"; fi; }

_DECLARED=$(mktemp) && sed -E -e '/^[[:space:]]*([#]|$)/d' -e 's/([[:space:]])+#.*$//' /etc/openrc/declare.conf | sort -u >"$_DECLARED"
_ENABLED=$(mktemp) && rc-update show default | awk '{print $1}' | sort -u >"$_ENABLED"

_ADD=$(mktemp) && comm -23 "$_DECLARED" "$_ENABLED" >"$_ADD"
_DEL=$(mktemp) && comm -23 "$_ENABLED" "$_DECLARED" >"$_DEL"

[ -s "$_ADD" ] && cat "$_ADD" | run_as_root xargs -I {} rc-update add {} default
[ -s "$_DEL" ] && cat "$_DEL" | run_as_root xargs -I {} rc-update del {}

rm -f "$_DECLARED" "$_ENABLED"
