#!/usr/bin/env bash

_clone_dotfiles_repository() {
  log_start 'Cloning' 'dotfiles repository'
  rm -fr "$DOTFILES_WORKSPACE"
  mkdir -p "$(dirname "$DOTFILES_WORKSPACE")"
  git clone --branch "$DOTFILES_DEFAULT_BRANCH" "$DOTFILES_REPOSITORY_URL" "$DOTFILES_WORKSPACE"
  log_ok
}

_update_dotfiles_repository() {
  git -C "$DOTFILES_WORKSPACE" fetch origin --prune &>/dev/null || return
  if log_check 'Checking if dotfiles repository is up to date' test \
    "$(git -C "$DOTFILES_WORKSPACE" rev-parse HEAD)" = \
    "$(git -C "$DOTFILES_WORKSPACE" rev-parse "origin/$DOTFILES_DEFAULT_BRANCH")"; then
    return
  fi
  log_start 'Updating' 'dotfiles repository'
  git -C "$DOTFILES_WORKSPACE" reset --hard HEAD
  git -C "$DOTFILES_WORKSPACE" clean -fdx
  git -C "$DOTFILES_WORKSPACE" checkout -B "$DOTFILES_DEFAULT_BRANCH" "origin/$DOTFILES_DEFAULT_BRANCH"
  git -C "$DOTFILES_WORKSPACE" reset --hard "origin/$DOTFILES_DEFAULT_BRANCH"
  log_ok
}

clone_dotfiles() {
  if log_check 'Checking if dotfiles repository exists' \
    test -d "$DOTFILES_WORKSPACE/.git"; then
    _update_dotfiles_repository
  else
    _clone_dotfiles_repository
  fi
}
