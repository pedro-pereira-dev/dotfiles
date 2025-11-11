#!/bin/sh
set -eou pipefail

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

is_root() { test "$(id -u)" -eq 0; }

run_as_root() { if is_root; then "$@"; elif check_command doas; then doas sh -c "$*"; elif check_command sudo; then sudo sh -c "$*"; fi; }

get_parameter --unattended "$@" >/dev/null && _ASK=--ask=n || _ASK=--ask=y

run_as_root emerge -cqv "$_ASK"

command -v eclean >/dev/null && eclean -Cqd distfiles && eclean -Cqd packages
command -v eclean-kernel >/dev/null && eclean-kernel -n 2 -s mtime
