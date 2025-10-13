#!/bin/sh
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-tmux.d/layer-bin-code.sh" "$_HOME/.local/bin/code"
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-tmux.d/layer-tmux.conf" "$_HOME/.config/tmux/tmux.conf"
