#!/usr/bin/env bash

_clone_dotfiles() {
  printf '\n%s\n' 'Cloning dotfiles repository'
  rm -fr "$DOTFILES_WORKSPACE"
  mkdir -p "$(dirname "$DOTFILES_WORKSPACE")"
  git clone -b "$DOTFILES_BRANCH" "$DOTFILES_URL" "$DOTFILES_WORKSPACE"
}

_update_dotfiles() {
  git -C "$DOTFILES_WORKSPACE" fetch origin --prune
  local _local _remote
  _local=$(git -C "$DOTFILES_WORKSPACE" rev-parse HEAD)
  _remote=$(git -C "$DOTFILES_WORKSPACE" rev-parse "origin/$DOTFILES_BRANCH")
  [[ $_local != "$_remote" ]] || return 0
  export DOTFILES_UPDATED=1
  printf '\n%s\n' 'Updating dotfiles repository'
  git -C "$DOTFILES_WORKSPACE" reset --hard HEAD
  git -C "$DOTFILES_WORKSPACE" clean -fdx
  git -C "$DOTFILES_WORKSPACE" checkout -B "$DOTFILES_BRANCH" "origin/$DOTFILES_BRANCH"
  git -C "$DOTFILES_WORKSPACE" reset --hard "origin/$DOTFILES_BRANCH"
}

maintain_dotfiles() {
  if [[ -d $DOTFILES_WORKSPACE/.git ]]; then
    _update_dotfiles
  else
    _clone_dotfiles
  fi
}
