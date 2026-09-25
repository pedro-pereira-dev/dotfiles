#!/usr/bin/env bash
set -euo pipefail

dots_pull() { log_info 'Using dotfiles from tarball for' "$(hostname -s)"; }
dots_sync() { log_info 'Nothing to sync for' "$(hostname -s)"; }
