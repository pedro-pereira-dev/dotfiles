#!/bin/bash
set -eou pipefail

_HOME="$(get_home "$@")"
_USER="$(get_user "$@")"

_LOCAL_DIR="$_HOME/$_DOTS_DIR"
_SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# symlinks dotfiles files to target system
run_as_user "$_USER" stow "$_SCRIPT_DIR/.bashrc" "$_HOME/.bashrc"
run_as_user "$_USER" stow "$_LOCAL_DIR/dots" "$_HOME/.local/bin/dots"
