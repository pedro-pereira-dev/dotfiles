#!/usr/bin/env bash
# shellcheck disable=SC2029,SC2154

dots_pull() {
  local -a ssh_opts
  local target
  local DOTS_FORCE=${DOTS_FORCE-}

  _git() {
    if command -v git >/dev/null; then
      git "$@" </dev/null
    else
      nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#git --command git "$@" </dev/null
    fi
  }

  dots_pull_clone() {
    rm -fr "$DOTFILES_WORKSPACE"
    mkdir -p "$(dirname "$DOTFILES_WORKSPACE")"
    _git clone -b "$DOTFILES_BRANCH" "$DOTFILES_URL" "$DOTFILES_WORKSPACE"
  }

  dots_pull_update() {
    _git -C "$DOTFILES_WORKSPACE" fetch origin --prune
    if [[ -n ${DOTS_FORCE-} ]]; then
      _git -C "$DOTFILES_WORKSPACE" checkout -f -B "$DOTFILES_BRANCH" "origin/$DOTFILES_BRANCH"
      _git -C "$DOTFILES_WORKSPACE" clean -fdx
      return
    fi
    if [[ -n $(_git -C "$DOTFILES_WORKSPACE" status --porcelain) ]]; then
      printf 'Workspace has local changes, commit them or use --force\n'
      return 1
    fi
    _git -C "$DOTFILES_WORKSPACE" merge --ff-only "origin/$DOTFILES_BRANCH"
  }

  dots_pull_maintain() {
    if [[ -d $DOTFILES_WORKSPACE/.git ]]; then
      dots_pull_update
    else
      dots_pull_clone
    fi
  }

  ssh_opts=(
    # prevents host key change errors
    -o StrictHostKeyChecking=no
    -o UserKnownHostsFile=/dev/null
  )

  if get_parameter --force "$@" >/dev/null; then
    DOTS_FORCE=1
  fi

  if ! get_parameter --self "$@" >/dev/null && ! get_parameter --target "$@" >/dev/null; then
    printf 'Usage: dots pull --self|--target U@HOST [--force]\n' >&2
    return 2
  fi

  target=$(select_target "$@")
  # starts ssh connection so ssh password prompt only happens here
  if [[ -n $target ]] && ! ssh "${ssh_opts[@]}" "$target" true; then
    exit 1
  fi

  if [[ -z $target ]]; then
    dots_pull_maintain
    return
  fi

  # the remote workspace is resolved from the remote user's home
  ssh "${ssh_opts[@]}" "$target" \
    "$(declare -f _git dots_pull_clone dots_pull_update dots_pull_maintain)
    DOTS_FORCE='${DOTS_FORCE-}' DOTFILES_URL='$DOTFILES_URL' DOTFILES_BRANCH='$DOTFILES_BRANCH' DOTFILES_WORKSPACE=\"\$HOME/workspace/personal/dotfiles\"
    export DOTS_FORCE DOTFILES_URL DOTFILES_BRANCH DOTFILES_WORKSPACE
    dots_pull_maintain"
}
