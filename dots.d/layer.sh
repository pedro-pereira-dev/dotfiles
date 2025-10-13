#!/bin/sh
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/dots" "$_HOME/.local/bin/dots"
