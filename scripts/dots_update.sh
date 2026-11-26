#!/usr/bin/env bash

dots_update() {
  if ! get_parameter --self "$@" >/dev/null && ! get_parameter --target "$@" >/dev/null; then
    printf 'Usage: dots update --self|--target U@HOST [--host NAME]\n' >&2
    return 2
  fi

  dots_pull --self
  exec "$DOTFILES_WORKSPACE/dots" setup "$@"
}
