#!/usr/bin/env bash

get_parameter() {
  local flag=$1
  shift
  while [[ $# -gt 0 ]]; do
    if [[ $1 == "$flag" ]]; then
      if [[ -n ${2-} && $2 != -* ]]; then printf '%s\n' "$2"; fi
      return 0
    fi
    shift
  done
  return 1
}
