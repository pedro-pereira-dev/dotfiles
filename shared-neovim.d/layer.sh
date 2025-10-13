#!/bin/sh
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-neovim.d/layer-bin-nvim-reloadable.sh" "$_HOME/.local/bin/nvim-reloadable"
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-neovim.d/layer-neovim-init.lua" "$_HOME/.config/nvim/init.lua"
