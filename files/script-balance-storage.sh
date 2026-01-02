#!/bin/sh
set -eou pipefail

get_parameter() {
  _get_parameter_flag=$1 && shift
  while [ $# -ge 1 ]; do
    _get_parameter_param=$1 && shift
    [ "$_get_parameter_flag" = "$_get_parameter_param" ] && {
      _get_parameter_val='' && [ $# -ge 1 ] && _get_parameter_val=$1
      # prints out if not starting by -
      [ -n "$_get_parameter_val" ] && expr "x$_get_parameter_val" : 'x[^-]' >/dev/null &&
        echo "$_get_parameter_val" || true
    } && return 0
  done && return 1
}

_pusage=$(get_parameter --pusage "$@") && [ -n "$_pusage" ] || _pusage=80 # percentage
_source=$(get_parameter --source "$@") && [ -n "$_source" ] || _source=/mnt/storage/fast
_target=$(get_parameter --target "$@") && [ -n "$_target" ] || _target=/mnt/storage/slow

get_source_files() { find "$_source" -not -type d -not -name '*.snapraid.content*' -printf '%A+ %p\n' | sort; }
get_usage() { df --output=pcent "$1" | tail -1 | sed 's/[^0-9]//g'; }
log() { echo "$1" && logger -p 'user.info' -t "$0" "$1"; }

_stats_counter=0
_stats_moved=0
_stats_timer_start=$(date +%s)

log "Archiving data from $_source ($(get_usage "$_source")%) to $_target ($(get_usage "$_target")%) - targetting $_pusage% usage"
_source_files=$(mktemp) && get_source_files >"$_source_files"
while read -r _file; do
  [ "$(get_usage "$_source")" -lt "$_pusage" ] && break

  _fpath=$(echo "$_file" | cut -d' ' -f2)
  _rpath=$(echo "$_fpath" | sed "s|^$_source/||")

  _size=$(find "$_fpath" -printf '%s')
  _stats_counter=$((_stats_counter + 1))
  _stats_moved=$((_stats_moved + _size))

  log "Moving from $_source ($(get_usage "$_source")%) $_target ($(get_usage "$_target")%) - $(numfmt --to=iec "$_size") ./$_rpath"
  rsync -axqHAXWESR --preallocate --remove-source-files "$_source/./$_rpath" "$_target/"
done <"$_source_files"
rm "$_source_files"

_stats_timer_end=$(date +%s)
log "Archived $(numfmt --to=iec "$_stats_moved") - $_stats_counter files from $_source ($(get_usage "$_source")%) to $_target ($(get_usage "$_target")%) in $((_stats_timer_end - _stats_timer_start)) seconds"
