#!/usr/bin/env bash

dots_pull() {
  if [[ -d $DOTFILES_WORKSPACE/.git ]]; then
    git -C "$DOTFILES_WORKSPACE" pull --ff-only
    DOTS_PULLED=$DOTFILES_WORKSPACE
  else
    DOTS_PULLED=$(mktemp -d)
    curl -fsSL "$DOTFILES_URL/archive/refs/heads/$DOTFILES_BRANCH.tar.gz" | tar -xz --strip-components=1 -C "$DOTS_PULLED"
  fi
  printf '%s\n' "$DOTS_PULLED"
}
