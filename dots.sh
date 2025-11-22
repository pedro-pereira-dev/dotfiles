#!/bin/sh
# shellcheck disable=SC2329 source=/dev/null
set -eou pipefail

delete_links() {
  $1 find "$2" -name '*' -type l 2>/dev/null | while IFS= read -r _LINK; do
    case $_LINK in /dev/* | /proc/* | /run/* | /sys/* | /tmp/*) continue ;; esac
    case $(find "$_LINK" -prune -printf '%l\n' 2>/dev/null)/ in
    "$_HOME/workspace/personal/dotfiles"/*) rm -v "$_LINK" &&
      # deletes _LINK empty parent directories
      find "$(dirname "$_LINK")" -depth -type d -empty -delete ;; esac
  done
}
delete_links_as_user() { delete_links run_as_user "$_HOME"; }
delete_links_as_root() { delete_links run_as_root /; }

dots_bootstrap() {
  [ -d "$_HOME/workspace/personal/dotfiles/.git" ] && return 0
  run_as_user mkdir -p "$_HOME/workspace/personal"
  run_as_user rm -fr "$_HOME/workspace/personal/dotfiles"
  run_as_user git clone https://github.com/pedro-pereira-dev/dotfiles.git "$_HOME/workspace/personal/dotfiles" || return 1
  return 0
}
dots_update() {
  run_as_user git -C "$_HOME/workspace/personal/dotfiles" fetch origin || return 1
  run_as_user git -C "$_HOME/workspace/personal/dotfiles" reset --hard origin/main || return 1
  run_as_user git -C "$_HOME/workspace/personal/dotfiles" clean -dfqx || return 1
  return 0
}
dots_sync() {
  . "$_HOME/workspace/personal/dotfiles/hosts/$_HOSTNAME/$_HOSTNAME.sh" || return 1
  configure "$@" || return 1
  return 0
}

get_parameter() {
  _FLAG='' && [ $# -ge 1 ] && _FLAG=$1 && shift
  while [ $# -ge 1 ]; do
    _PARAM='' && [ $# -ge 1 ] && _PARAM=$1 && shift
    [ "$_FLAG" = "$_PARAM" ] && {
      _VAL='' && [ $# -ge 1 ] && _VAL=$1
      # prints if it does not start with -
      [ -n "$_VAL" ] && expr "x$_VAL" : 'x[^-]' >/dev/null && echo "$_VAL"
      return 0
    }
  done
  return 1
}

is_linux() { test "$(uname)" = Linux; }
is_macos() { test "$(uname)" = Darwin; }

is_non_root() { ! is_root; }
is_root() { test "$(id -u)" -eq 0; }

link_as_root() { run_as_root rm -fr "$2" && run_as_root mkdir -p "$(dirname "$2")" && run_as_root ln -fsv "$1" "$2"; }
link_as_user() { run_as_user rm -fr "$2" && run_as_user mkdir -p "$(dirname "$2")" && run_as_user ln -fsv "$1" "$2"; }

run_as_root() { if is_root; then "$@"; elif command -v doas >/dev/null; then doas "$@"; elif command -v sudo >/dev/null; then sudo "$@"; fi; }
run_as_user() { if is_non_root; then "$@"; elif is_root; then su "$_USER" -c "$(printf '%s ' "$@")"; fi; }

setup_doas() {
  { ! command -v doas >/dev/null && run_as_root emerge --ask=n -n app-admin/doas || true; } &&
    run_as_root cp -f "$_HOME/workspace/personal/dotfiles/files/system-doas.conf" /etc/doas.conf &&
    run_as_root chown root:root /etc/doas.conf && run_as_root chmod 0600 /etc/doas.conf && run_as_root passwd -dl root >/dev/null
}

_HOSTNAME=$(get_parameter --hostname "$@") && [ -n "$_HOSTNAME" ] ||
  { is_linux && _HOSTNAME=$(cat /etc/hostname) || is_macos && _HOSTNAME=$(hostname); } ||
  { echo '[E] missing required argument --hostname' && exit 1; }
_USER=$(get_parameter --user "$@") && [ -n "$_USER" ] ||
  { is_non_root && _USER=$(whoami) || is_root && _USER=$(grep ^wheel: /etc/group | cut -d, -f2 | grep -v root); } ||
  { echo '[E] missing required argument --user' && exit 1; }

is_linux && _HOME=/home/$_USER
is_macos && _HOME=/Users/$_USER

_CMD='' && [ "$#" -ge 1 ] && _CMD="$1" && shift
case $_CMD in

update) dots_bootstrap && dots_update || exit 1 ;;
sync) dots_bootstrap && dots_sync "$@" || exit 1 ;;

*) exit 1 ;;
esac
exit 0
