#!/bin/sh
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-git.d/layer-gitconfig-default.conf" "$_HOME/.gitconfig.default"
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-git.d/layer-gitconfig-mercedes.conf" "$_HOME/.gitconfig.mercedes"
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-git.d/layer-gitconfig.conf" "$_HOME/.gitconfig"
