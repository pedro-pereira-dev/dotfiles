#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

export DOTFILES_WORKSPACE=${DOTFILES_WORKSPACE:-$HOME/workspace/personal/dotfiles}
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
  local _preview _answer
  _preview=$("_preview_$3" 2>&1)
  [[ -n $_preview ]] || return 0
  if ! ((_force)); then
    printf '%s\n' "$_preview"
    read -rp "$1 $2? [Y/n] " _answer
    [[ -z $_answer || $_answer == [yY]* ]] || return 0
  fi
  "_apply_$3"
}

brew update || true
_is_in_sync && exit
((_check)) && exit 1

_step 'Install' 'homebrew packages' install
_step 'Remove' 'homebrew packages' remove
_step 'Clean up' 'homebrew packages and artifacts' clean
