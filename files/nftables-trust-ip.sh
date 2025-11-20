#!/bin/sh
set -eou pipefail

is_root() { test "$(id -u)" -eq 0; }
run_as_root() { if is_root; then "$@"; elif command -v doas >/dev/null; then doas "$@"; elif command -v sudo >/dev/null; then sudo "$@"; fi; }

run_as_root nft list ruleset
exit 0
