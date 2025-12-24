#!/bin/sh
set -eou pipefail

get_parameter() {
  _get_parameter_flag=$1 && shift
  while [ $# -ge 1 ]; do
    _get_parameter_param=$1 && shift
    [ "$_get_parameter_flag" != "$_get_parameter_param" ] && continue
    _get_parameter_val='' && [ $# -ge 1 ] && _get_parameter_val=$1
    [ -n "$_get_parameter_val" ] &&
      expr "x$_get_parameter_val" : 'x[^-]' >/dev/null &&
      echo "$_get_parameter_val"
    return 0
  done
  return 1
}

! get_parameter --lock && ! get_parameter --unlock && exit 1

_source=$(get_parameter --source "$@") && [ -n "$_source" ] || exit 1
_target=$(get_parameter --target "$@") && [ -n "$_target" ] || exit 1

get_parameter --lock >/dev/null &&
  gpg --cipher-algo AES256 --pinentry-mode loopback \
    --s2k-count 65011712 --s2k-digest-algo SHA512 --s2k-mode 3 \
    -c -o "$_target" "$_source" &&
  exit 0

get_parameter --unlock >/dev/null &&
  gpg --pinentry-mode loopback -d -o "$_target" "$_source" &&
  exit 0

exit 1
