#!/bin/sh
set -eou pipefail

is_root() { test "$(id -u)" -eq 0; }
run_as_root() { if is_root; then "$@"; elif command -v doas >/dev/null; then doas "$@"; elif command -v sudo >/dev/null; then sudo "$@"; fi; }

_ASK=--ask=y && [ $# -eq 1 ] && [ "$1" = --unattended ] && _ASK=--ask=n
run_as_root emerge -DNquv $_ASK --backtrack=30 --with-bdeps=y @world || true

exit 0
