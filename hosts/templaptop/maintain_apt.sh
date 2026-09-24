#!/usr/bin/env bash
# shellcheck disable=SC1091
set -euo pipefail

export DOTFILES_WORKSPACE=${DOTFILES_WORKSPACE:-$HOME/workspace/personal/dotfiles}
source "$DOTFILES_WORKSPACE/utils/logging.sh"

_aptfile=$HOME/.Aptfile
_state=${XDG_STATE_HOME:-$HOME/.local/state}/dots/aptfile

_check=0 _yes=()
for _arg; do
  case $_arg in
  --check) _check=1 ;;
  --force) _yes=(-y) ;;
  esac
done

_apt() { sudo apt "${_yes[@]}" "$@"; }
_wanted() { grep -v '^[[:space:]]*\(#\|$\)' "$_aptfile" | sort -u; }
_installed() { (($#)) && dpkg-query -W -f='${Package} ${db:Status-Status}\n' "$@" 2>/dev/null | awk '$2 == "installed" { print $1 }'; }
_missing() { comm -23 <(_wanted) <(_installed $(_wanted) | sort -u); }
_stale() { [[ -f $_state ]] && _installed $(comm -23 <(sort -u "$_state") <(_wanted)); }
_save_state() { mkdir -p "${_state%/*}" && _wanted >"$_state"; }
_is_in_sync() { [[ -z $(_preview_install) && -z $(_preview_remove) ]]; }

_preview_clean() { apt -s autoremove --purge 2>/dev/null | sed -n 's/^Purg \([^ ]*\).*/\1/p'; }
_preview_install() {
  _missing
  apt list --upgradable 2>/dev/null | sed -n 's|/.*||p'
}
_preview_remove() { _stale || true; }

_apply_clean() {
  _apt autoremove --purge
  sudo apt clean
}
_apply_install() {
  # shellcheck disable=SC2046
  _apt install $(_missing)
  _apt upgrade
}
# shellcheck disable=SC2046
_apply_remove() { _apt remove $(_stale); }

_step() {
  local _preview
  _preview=$("_preview_$4" 2>&1)
  [[ -n $_preview ]] || return 0
  if ((${#_yes[@]} == 0)); then
    log_start 'Previewing' "$3"
    printf '%s\n' "$_preview"
    log_ok
    log_question "$1" "$2?" || return 0
  fi
  log_start "$1" "$2"
  "_apply_$4"
  log_ok
}

log_start 'Maintaining' 'apt'
log_start 'Updating' 'apt'
sudo apt update || true
log_ok
if log_check 'Checking apt packages' _is_in_sync; then _save_state && log_ok && exit; fi
((_check)) && log_ok && exit 1

_step 'Installing' 'apt packages' 'apt packages to install' install
_step 'Removing' 'apt packages' 'apt packages to remove' remove
_step 'Cleaning up' 'apt packages and artifacts' 'apt packages and artifacts' clean
_save_state
log_ok
