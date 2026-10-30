#!/usr/bin/env bash

dots_update() {
  dots_pull --self
  exec "$DOTFILES_WORKSPACE/dots" setup "$@"
}
