#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

export DOTFILES_WORKSPACE=${DOTFILES_WORKSPACE:-$HOME/workspace/personal/dotfiles}
source "$DOTFILES_WORKSPACE/utils/logging.sh"
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
export HOMEBREW_NO_ENV_HINTS=1

_check=0 _force=0
for _arg; do
  case $_arg in
  --check) _check=1 ;;
  --force) _force=1 && export HOMEBREW_NO_ASK=1 ;;
  esac
done

_bundle_check() { brew bundle check --global --no-upgrade "$@"; }
_cleanup_dry() { brew bundle cleanup --global </dev/null 2>&1; }
_is_in_sync() { _bundle_check && [[ -z $(brew outdated) && $(_cleanup_dry) != *'Would uninstall'* ]]; }

_preview_clean() {
  brew autoremove --dry-run
  brew cleanup --prune=all -s --dry-run
}
_preview_install() {
  _bundle_check --verbose 2>&1 | sed -n 's/^→ [A-Za-z]* \([^ ]*\) needs.*/\1/p' || true
  brew outdated --quiet 2>/dev/null || true
}
_preview_remove() {
  _cleanup_dry |
    awk '/brew cleanup`:/{exit} /^(Would|Run|==>)|Do you want|Invalid input/{next} {for(i=1;i<=NF;i++) print $i}' |
    grep -Fxf <(
      brew leaves --installed-on-request
      brew list --cask -1
    ) || true
}

_apply_clean() {
  brew autoremove
  brew cleanup --prune=all -s
}
_apply_install() { brew bundle install --global --upgrade; }
_apply_remove() { brew bundle cleanup --global --force; }

_step() {
  local _preview
  _preview=$("_preview_$4" 2>&1)
  [[ -n $_preview ]] || return 0
  if ! ((_force)); then
    log_start 'Previewing' "$3"
    printf '%s\n' "$_preview"
    log_ok
    log_question "$1" "$2?" || return 0
  fi
  log_start "$1" "$2"
  "_apply_$4"
  log_ok
}

log_start 'Maintaining' 'homebrew'
log_start 'Updating' 'homebrew'
brew update || true
log_ok
if log_check 'Checking homebrew packages' _is_in_sync; then log_ok && exit; fi
((_check)) && log_ok && exit 1

_step 'Installing' 'homebrew packages' 'homebrew packages to install' install
_step 'Removing' 'homebrew packages' 'homebrew packages to remove' remove
_step 'Cleaning up' 'homebrew packages and artifacts' 'homebrew packages and artifacts' clean
log_ok
