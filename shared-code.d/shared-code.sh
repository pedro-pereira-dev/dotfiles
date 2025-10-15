#!/bin/sh
is_linux && run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-code.d/setup-confs/lazygit-config.yml" "$_HOME/.config/lazygit/config.yml"
is_macos && run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-code.d/setup-confs/lazygit-config.yml" "$_HOME/Library/Application Support/lazygit/config.yml"
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-code.d/setup-confs/neovim-init.lua" "$_HOME/.config/nvim/init.lua"
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-code.d/setup-confs/nvim-reloadable" "$_HOME/.local/bin/"
