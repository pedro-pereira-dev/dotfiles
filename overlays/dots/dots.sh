#!/bin/sh
set -eou pipefail

run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/dots" "$_HOME/.local/bin/dots"
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/overlays/dots/files/system-bashrc.sh" "$_HOME/.bashrc"

is_gentoo && {
  run_as_root stow "$_HOME/$_DOTS_DIR/overlays/dots/files/dots-package-declare.conf" /etc/portage/package.declare/1-dots-declare.conf
} || true
