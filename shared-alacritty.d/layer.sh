#!/bin/sh
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-alacritty.d/layer-alacritty.toml" "$_HOME/.config/alacritty/alacritty.toml"
