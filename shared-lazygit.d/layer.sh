#!/bin/sh
is_linux && run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-lazygit.d/layer-lazygit-config.yml" "$_HOME/.config/lazygit/config.yml"
is_macos && run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-lazygit.d/layer-lazygit-config.yml" "$_HOME/Library/Application Support/lazygit/config.yml"
