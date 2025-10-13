#!/bin/sh
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-bash.d/dot-bashrc.sh" "$_HOME/.bashrc"
