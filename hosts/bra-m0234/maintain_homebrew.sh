#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

export DOTFILES_WORKSPACE=${DOTFILES_WORKSPACE:-$HOME/workspace/personal/dotfiles}
source "$DOTFILES_WORKSPACE/utils/logging.sh"

_is_in_sync() { brew bundle check --global --no-upgrade &&
  [[ -z $(brew outdated) && $(brew bundle cleanup --global) != *'Would uninstall'* ]]; }

_run() {
  [[ ${_flag-} == --force ]] ||
    log_question "$1" "$2?" || return 0
  log_start "$1" "$2"
  "${@:3}"
  log_ok
}

_flag=${1-}
export HOMEBREW_NO_ENV_HINTS=1
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

log_check 'Updating homebrew' brew update --quiet || true
log_check 'Checking homebrew packages' _is_in_sync && exit
[[ $_flag == --check ]] && exit 1

_run 'Installing' 'packages' brew bundle install --global --upgrade
_run 'Removing' 'packages' brew bundle cleanup --global --force
_run 'Cleaning up' 'dependencies and artifacts' eval 'brew autoremove && brew cleanup --prune=all -s'
