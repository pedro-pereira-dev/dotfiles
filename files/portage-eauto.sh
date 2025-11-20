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

get_parameter --unattended "$@" >/dev/null && _UNATTENDED=--unattended || _UNATTENDED=''

eupdate
eupgrade "$_UNATTENDED"
edeclare "$_UNATTENDED"
edelete "$_UNATTENDED"
exit 0
