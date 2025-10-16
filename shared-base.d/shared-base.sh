#!/bin/sh
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/dots" "$_HOME/.local/bin/dots"
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-base.d/shared-confs/ssh.conf" "$_HOME/.ssh/config"
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-base.d/shared-confs/tmux.conf" "$_HOME/.config/tmux/tmux.conf"
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-base.d/shared-tools/" "$_HOME/.local/bin/"
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-base.d/user-confs/" "$_HOME/"
