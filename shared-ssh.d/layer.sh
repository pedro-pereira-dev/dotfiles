#!/bin/sh
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-ssh.d/layer-ssh-config.conf" "$_HOME/.ssh/config"
