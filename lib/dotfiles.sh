#!/usr/bin/env bash

_clone_dotfiles() {
  rm -fr "$DOTFILES_WORKSPACE"
  mkdir -p "$(dirname "$DOTFILES_WORKSPACE")"
  git clone -b "$DOTFILES_BRANCH" "$DOTFILES_URL" "$DOTFILES_WORKSPACE"
}

_update_dotfiles() {
  _previous=$(git -C "$DOTFILES_WORKSPACE" rev-parse HEAD)
  git -C "$DOTFILES_WORKSPACE" fetch origin --prune
  git -C "$DOTFILES_WORKSPACE" checkout -f -B "$DOTFILES_BRANCH" "origin/$DOTFILES_BRANCH"
  git -C "$DOTFILES_WORKSPACE" clean -fdx
  if [[ $_previous != "$(git -C "$DOTFILES_WORKSPACE" rev-parse HEAD)" ]]; then
    export DOTFILES_UPDATED=1
  fi
}

maintain_dotfiles() {
  if [[ -d $DOTFILES_WORKSPACE/.git ]]; then
    _update_dotfiles
  else
    _clone_dotfiles
  fi
}
