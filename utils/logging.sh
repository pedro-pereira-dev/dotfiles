#!/usr/bin/env bash

_log_green_bold=$'\033[1;32m'
_log_light_red_bold=$'\033[1;91m'
_log_magenta=$'\033[0;95m'
_log_magenta_bold=$'\033[1;35m'
_log_orange=$'\033[0;33m'
_log_orange_bold=$'\033[1;33m'
_log_red=$'\033[0;31m'
_log_red_bold=$'\033[1;31m'
_log_reset=$'\033[0m'

# nesting depth: '*' and '-' top level, '**' and '=' nested, '***' and '#' deeper
_log_bullets=('*' '**' '***')
_log_dividers=(
  '----------------------------------------------------------------'
  '================================================================'
  '################################################################'
)

_log_actions=()
_log_starts=()
_log_subjects=()
export _log_after_ok=${_log_after_ok:-0}

_log_depth() {
  _log_d=${#_log_actions[@]}
  ((_log_d <= 2)) || _log_d=2
}

_log_line() {
  _log_after_ok=0
  _log_depth
  printf '%s %s%s %s%s%s%s\n' \
    "${_log_bullets[_log_d]}" "$1" "$3" "$2" "$4" "$_log_reset" "${5-}"
}

# * Checking Git configuration... OK
log_check() {
  _log_after_ok=0
  _log_depth
  printf '%s %s%s...%s ' "${_log_bullets[_log_d]}" "$_log_orange" "$1" "$_log_reset"
  local _status=0
  "${@:2}" &>/dev/null || _status=$?
  case $_status in
  0) printf '%sOK%s\n' "$_log_green_bold" "$_log_reset" ;;
  *) printf '%sNOK%s\n' "$_log_red_bold" "$_log_reset" ;;
  esac
  return "$_status"
}

# * Updating host-one
log_info() { _log_line "$_log_magenta" "$_log_magenta_bold" "$1" "$2"; }

# * No host configuration found for host-one
log_fail() { _log_line "$_log_red" "$_log_light_red_bold" "$1" "$2" >&2; }

# * Updating host-one
# ----------------------------------------
log_start() {
  ((${#_log_actions[@]} > 0 || _log_after_ok)) || printf '\n'
  _log_line "$_log_magenta" "$_log_magenta_bold" "$1" "$2"
  printf '%s\n' "${_log_dividers[_log_d]}"
  _log_actions+=("$1")
  _log_subjects+=("$2")
  _log_starts+=("$SECONDS")
}

# ----------------------------------------
# * Updating host-one... OK (executed in 4s)
log_ok() {
  local _i=$((${#_log_actions[@]} - 1))
  local _action=${_log_actions[_i]}
  local _subject=${_log_subjects[_i]}
  local _elapsed=$((SECONDS - _log_starts[_i]))
  unset "_log_actions[_i]" "_log_subjects[_i]" "_log_starts[_i]"
  _log_depth
  printf '%s\n' "${_log_dividers[_log_d]}"
  _log_line "$_log_magenta" "$_log_magenta_bold" "$_action" "$_subject" \
    "... ${_log_green_bold}OK${_log_reset} (executed in ${_log_orange_bold}${_elapsed}s${_log_reset})"
  ((${#_log_actions[@]} > 0)) || { printf '\n' && _log_after_ok=1; }
}
