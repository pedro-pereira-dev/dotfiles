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

get_files() { find "$1" -not -type d -not -name '*.snapraid.content*' -printf '%A+ %p\n' | sort; }
get_usage() { df --output=pcent "$1" | tail -1 | sed 's/[^0-9]//g'; }

_pusage=$(get_parameter --pusage "$@") && [ -n "$_pusage" ] || _pusage=80
_source=$(get_parameter --source "$@") && [ -n "$_source" ] && _source="${_source%/}" || _source=/mnt/storage/fast
_target=$(get_parameter --target "$@") && [ -n "$_target" ] && _target="${_target%/}" || _target=/mnt/storage/slow

[ "$(get_usage "$_source")" -lt "$_pusage" ] && {
  printf 'Nothing to do %s %s%% ' "$_source" "$(get_usage "$_source")"
  printf 'less than target %s%% ' "$_pusage"
  echo && exit 0
}

printf 'Uncaching for %s%% usage ' "$_pusage"
printf 'from %s %s%% ' "$_source" "$(get_usage "$_source")"
printf 'to %s %s%%   ' "$_target" "$(get_usage "$_target")"
echo

_stats_counter=0
_stats_moved=0
_stats_timer_start=$(date +%s)

_source_files=$(mktemp)
get_files "$_source" >"$_source_files"
while read -r _file; do
  [ "$(get_usage "$_source")" -lt "$_pusage" ] && break

  _fpath=$(echo "$_file" | cut -d' ' -f2)
  _rpath=$(echo "$_fpath" | sed "s|^$_source/||")

  _size=$(find "$_fpath" -printf '%s')
  _stats_counter=$((_stats_counter + 1))
  _stats_moved=$((_stats_moved + _size))

  rsync -axqHAXWESR --preallocate --remove-source-files "$_source/./$_rpath" "$_target/"
  printf '%6s %5s ./%s \n' \
    "($(get_usage "$_source")%)" \
    "$(numfmt --to=iec "$_size")" \
    "$_rpath"

done <"$_source_files"
rm "$_source_files"

_stats_timer_end=$(date +%s)

printf 'Uncached '
printf '%s - %s file(s) in %s seconds \n' \
  "$(numfmt --to=iec "$_stats_moved")" \
  $_stats_counter \
  $((_stats_timer_end - _stats_timer_start))
