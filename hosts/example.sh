#!/usr/bin/env bash
set -euo pipefail

dots_pull() { printf '\n%s\n' "Using dotfiles from tarball for $(hostname -s)"; }
dots_sync() { printf '\n%s\n' "Nothing to sync for $(hostname -s)"; }
