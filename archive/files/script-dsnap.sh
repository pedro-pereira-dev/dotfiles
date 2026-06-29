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

_max_deleted=$(get_parameter --max-deleted "$@") && [ -n "$_max_deleted" ] || _max_deleted=10
_max_updated=$(get_parameter --max-updated "$@") && [ -n "$_max_updated" ] || _max_updated=30

_diff=$(snapraid diff | grep '^ *[0-9]* ') || true
get_diff_value() { echo "$_diff" | grep " $1" | awk '{print $1}'; }

_diff_add=$(get_diff_value 'added')
_diff_del=$(get_diff_value 'removed')
_diff_mov=$(get_diff_value 'moved')
_diff_upd=$(get_diff_value 'updated')
_diffs=$((_diff_add + _diff_del + _diff_mov + _diff_upd))

printf 'Snapraid thresholds: %s deletion and %s update \n' "$_max_deleted" "$_max_updated"
printf 'Snapraid summary: %s add, %s del, %s mov and %s upd \n' \
  "$_diff_add" \
  "$_diff_del" \
  "$_diff_mov" \
  "$_diff_upd"

! get_parameter --force "$@" >/dev/null && [ "$_diff_del" -ge "$_max_deleted" ] &&
  echo "Too many file(s) deleted $_diff_del, use --force to ignore" &&
  exit 1
! get_parameter --force "$@" >/dev/null && [ "$_diff_upd" -ge "$_max_updated" ] &&
  echo "Too many file(s) updated $_diff_upd, use --force to ignore" &&
  exit 1

[ $_diffs -gt 0 ] && { snapraid --force-empty --force-full --force-zero sync || exit 1; }
snapraid scrub && snapraid status || exit 1
