#!/bin/sh
# shellcheck disable=SC2015 source=/dev/null
set -eou pipefail

[ $# -ge 2 ] && [ "$1" = install ] && [ "$2" = gentoo ] &&
  curl -Lfs -- https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/install-gentoo.sh | sh -s -- "$@"

get_parameter() {
  _NAME='' && [ $# -ge 1 ] && _NAME=$1 && shift
  while [ $# -ge 1 ]; do
    _PARAM=$1 && shift
    if [ "$_NAME" = "$_PARAM" ]; then
      [ $# -ge 1 ] && _VAL=$1 && expr "x$_VAL" : 'x[^-]' >/dev/null && echo "$_VAL"
      return 0
    fi
  done
  return 1
}

is_linux() { test "$(uname)" = Linux; }
is_macos() { test "$(uname)" = Darwin; }

is_non_root() { ! is_root; }
is_root() { test "$(id -u)" -eq 0; }

link_as_root() { run_as_root rm -fr "$2" && run_as_root mkdir -p "$(dirname "$2")" && run_as_root ln -fsv "$1" "$2"; }
link_as_user() { run_as_user rm -fr "$2" && run_as_user mkdir -p "$(dirname "$2")" && run_as_user ln -fsv "$1" "$2"; }

run_as_root() { if is_root; then "$@"; elif check_command doas; then doas sh -c "$*"; elif check_command sudo; then sudo sh -c "$*"; fi; }
run_as_user() { if is_non_root; then "$@"; elif is_root; then su "$_USER" -c "$*"; fi; }

_HOSTNAME=$(get_parameter --hostname "$@") && [ -n "$_HOSTNAME" ] ||
  { is_linux && _HOSTNAME=$(cat /etc/hostname); } ||
  { is_macos && _HOSTNAME=$(hostname); } ||
  { echo '[E] missing required argument --hostname' && exit 1; }
_USER=$(get_parameter --user "$@") && [ -n "$_USER" ] ||
  { is_root && _USER=$(grep ^wheel: /etc/group | cut -d, -f2 | grep -v root); } ||
  { is_non_root && _USER=$(whoami); } ||
  { echo '[E] missing required argument --user' && exit 1; }
{ is_macos && _HOME=/Users/$_USER; } || { is_linux && _HOME=/home/$_USER; }

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
  . "$_HOME/workspace/personal/dotfiles/hosts/$_HOSTNAME/$_HOSTNAME.sh"
  ! configure "$(get_parameter --full "$@" >/dev/null && echo --full)" && return 1
  return 0
}

_CMD='' && [ "$#" -ge 1 ] && _CMD="$1" && shift
case $_CMD in
update) dots_bootstrap && dots_update ;;
sync) dots_bootstrap && dots_sync "$@" ;;
*) exit 1 ;;
esac
