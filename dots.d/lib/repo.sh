#!/usr/bin/env bash

dots_pull() {
  local path=$DOTFILES_WORKSPACE
  if [[ -d $path/.git ]]; then
    git -C "$path" pull --ff-only >&2
  else
    path=$(mktemp -d)
    curl -fsSL "$DOTFILES_URL/archive/refs/heads/$DOTFILES_BRANCH.tar.gz" | tar -xz --strip-components=1 -C "$path"
  fi
  printf '%s\n' "$path"
}

dots_update() {
  dots_pull >/dev/null
  exec "$DOTS_ROOT/dots" setup "$@"
}
