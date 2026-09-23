#!/usr/bin/env bash

_log_green_bold=$'\033[1;32m'
_log_light_blue=$'\033[0;94m'
_log_magenta=$'\033[0;95m'
_log_magenta_bold=$'\033[1;35m'
_log_orange=$'\033[0;33m'
_log_orange_bold=$'\033[1;33m'
_log_red_bold=$'\033[1;31m'
_log_reset=$'\033[0m'

_log_divider='----------------------------------------------------------------'
_log_nested_divider='================================================================'
_log_stack=()

# bullet reflects nesting depth: '*' top level, '**' nested, '***' deeper
_log_bullet() {
  local _depth=$(( ${1:-${#_log_stack[@]}} / 3 ))
  local _bullet='*'
  while ((_depth-- > 0 && ${#_bullet} < 3)); do _bullet+='*'; done
  printf '%s' "$_bullet"
}

_log_divider_for() {
  if ((${1:-${#_log_stack[@]}} == 0)); then
    printf '%s' "$_log_divider"
  else
    printf '%s' "$_log_nested_divider"
  fi
}

# * Checking Git configuration... OK
log_check() {
  local _bullet
  _bullet=$(_log_bullet)
  [[ ${DOTS_VERBOSE:-false} != true ]] ||
    printf '%s %s%s...%s ' "$_bullet" "$_log_orange" "$1" "$_log_reset"
  shift
  local _status=0
  "$@" &>/dev/null || _status=$?
  if [[ ${DOTS_VERBOSE:-false} == true ]]; then
    case $_status in
    0) printf '%sOK%s\n' "$_log_green_bold" "$_log_reset" ;;
    *) printf '%sNOK%s\n' "$_log_red_bold" "$_log_reset" ;;
    esac
  fi
  return "$_status"
}

# * Updating host-one
log_info() {
  local _bullet
  _bullet=$(_log_bullet)
  printf '%s %s%s %s%s%s\n' \
    "$_bullet" "$_log_magenta" "$1" "$_log_magenta_bold" "$2" "$_log_reset"
}

# ----------------------------------------
# * Updating host-one... OK (executed in 4s)
log_ok() {
  if ((${#_log_stack[@]} < 3)); then
    printf 'log_ok: called without a matching log_start\n' >&2
    return 1
  fi
  local _index=$((${#_log_stack[@]} - 3))
  local _action=${_log_stack[_index]}
  local _subject=${_log_stack[_index + 1]}
  local _elapsed=$((SECONDS - _log_stack[_index + 2]))
  local _duration="${_elapsed}s"
  local _bullet _divider
  _bullet=$(_log_bullet "$_index")
  _log_stack=("${_log_stack[@]:0:_index}")
  _divider=$(_log_divider_for)
  if ((_elapsed >= 60)); then
    _duration="$((_elapsed / 60))m $((_elapsed % 60))s"
  fi
  printf '%s%s\n' "$_log_reset" "$_divider"
  printf '%s %s%s %s%s%s... %sOK%s (executed in %s%s%s)\n' \
    "$_bullet" "$_log_magenta" "$_action" \
    "$_log_magenta_bold" "$_subject" "$_log_light_blue" \
    "$_log_green_bold" "$_log_reset" \
    "$_log_orange_bold" "$_duration" "$_log_reset"
  ((${#_log_stack[@]} > 0)) || printf '\n'
}

# * Updating host-one
# ----------------------------------------
log_start() {
  local _bullet _divider
  _bullet=$(_log_bullet)
  _divider=$(_log_divider_for)
  _log_stack+=("$1" "$2" "$SECONDS")
  printf '\n%s %s%s %s%s%s\n' "$_bullet" "$_log_magenta" "$1" "$_log_magenta_bold" "$2" "$_log_reset"
  printf '%s%s\n' "$_log_reset" "$_divider"
}
