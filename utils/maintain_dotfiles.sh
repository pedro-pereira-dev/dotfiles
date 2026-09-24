#!/usr/bin/env bash

_clone_dotfiles() {
  log_start 'Cloning' 'dotfiles repository'
  rm -fr "$DOTFILES_WORKSPACE"
  mkdir -p "$(dirname "$DOTFILES_WORKSPACE")"
  git clone -b "$DOTFILES_BRANCH" "$DOTFILES_URL" "$DOTFILES_WORKSPACE"
  log_ok
}

_update_dotfiles() {
  git -C "$DOTFILES_WORKSPACE" fetch origin --prune &>/dev/null ||
    { log_fail 'Failed to fetch' 'dotfiles repository' && return 1; }
  if log_check 'Checking if dotfiles repository is up to date' test \
    "$(git -C "$DOTFILES_WORKSPACE" rev-parse HEAD)" = \
    "$(git -C "$DOTFILES_WORKSPACE" rev-parse "origin/$DOTFILES_BRANCH")"; then
    return
  fi
  export DOTFILES_UPDATED=1
  log_start 'Updating' 'dotfiles repository'
  git -C "$DOTFILES_WORKSPACE" reset --hard HEAD
  git -C "$DOTFILES_WORKSPACE" clean -fdx
  git -C "$DOTFILES_WORKSPACE" checkout -B "$DOTFILES_BRANCH" "origin/$DOTFILES_BRANCH"
  git -C "$DOTFILES_WORKSPACE" reset --hard "origin/$DOTFILES_BRANCH"
  log_ok
}

maintain_dotfiles() {
  if log_check 'Checking if dotfiles repository exists' \
    test -d "$DOTFILES_WORKSPACE/.git"; then
    _update_dotfiles
  else
    _clone_dotfiles
  fi
}
