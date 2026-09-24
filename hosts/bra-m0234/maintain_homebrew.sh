#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

export DOTFILES_WORKSPACE=${DOTFILES_WORKSPACE:-$HOME/workspace/personal/dotfiles}
source "$DOTFILES_WORKSPACE/utils/logging.sh"

_has_missing_packages() { ! brew bundle check --global --no-upgrade &>/dev/null; }
_has_outdated_packages() { [[ -n $(brew outdated 2>/dev/null) ]]; }
_has_undeclared_packages() { [[ $(brew bundle cleanup --global 2>/dev/null) == *'Would uninstall'* ]]; }
_has_orphan_packages() { [[ -n $(brew autoremove --dry-run 2>/dev/null) ]]; }
_has_artifacts() { [[ -n $(brew cleanup --prune=all -s --dry-run 2>/dev/null) ]]; }
_is_in_sync() { ! _has_missing_packages && ! _has_undeclared_packages && ! _has_outdated_packages; }

_install_declared() {
  _has_missing_packages || _has_outdated_packages || return 0
  log_start 'Installing' 'packages'
  brew bundle install --global --upgrade | { grep -v '^Using ' || true; }
  log_ok
}

_remove_undeclared() {
  _has_undeclared_packages || _has_orphan_packages || return 0
  log_start 'Removing' 'packages'
  brew bundle cleanup --global --force
  brew autoremove
  log_ok
}

_cleanup_artifacts() {
  _has_artifacts || return 0
  log_start 'Cleaning up' 'artifacts'
  brew cleanup --prune=all -s
  log_ok
}

_update() {
  log_start 'Maintaining' 'homebrew'
  _install_declared
  _remove_undeclared
  _cleanup_artifacts
  log_ok
}

export HOMEBREW_NO_ENV_HINTS=1
if ! command -v brew &>/dev/null; then
  [[ -x /opt/homebrew/bin/brew ]] ||
    { log_fail 'Command not found' 'brew' && exit 1; }
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

log_check 'Updating homebrew' brew update --quiet || true
log_check 'Checking homebrew packages' _is_in_sync && exit
[[ ${1-} == --check ]] && exit 1
_update
