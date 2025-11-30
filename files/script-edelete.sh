#!/bin/sh
set -eou pipefail

is_root() { test "$(id -u)" -eq 0; }
run_as_root() { if is_root; then "$@"; elif command -v doas >/dev/null; then doas "$@"; elif command -v sudo >/dev/null; then sudo "$@"; fi; }

_ASK=--ask=y && [ $# -eq 1 ] && [ "$1" = --unattended ] && _ASK=--ask=n
run_as_root emerge -cqv $_ASK

_OPTS='-A' && [ $# -eq 1 ] && [ "$1" = --unattended ] && _OPTS=''
command -v eclean-kernel >/dev/null && run_as_root eclean-kernel -n 1 -s mtime $_OPTS || true
