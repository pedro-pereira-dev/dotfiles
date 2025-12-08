#!/bin/sh
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/gentoo-desktop.d/desktop-confs/gtk-config.toml" "$_HOME/.config/gtk-3.0/settings.ini"
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/gentoo-desktop.d/desktop-confs/gtk-config.toml" "$_HOME/.config/gtk-4.0/settings.ini"
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/gentoo-desktop.d/desktop-confs/sway.conf" "$_HOME/.config/sway/config"
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/gentoo-desktop.d/desktop-tools/" "$_HOME/.local/bin/"
