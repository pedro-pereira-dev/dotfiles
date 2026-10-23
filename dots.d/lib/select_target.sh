#!/usr/bin/env bash

select_target() {
  local self="" target=""
  if get_parameter --self "$@" >/dev/null; then self=1; fi
  if get_parameter --target "$@" >/dev/null; then
    target=$(get_parameter --target "$@")
    if [[ -z $target ]]; then
      printf '"--target" requires a host\n'
      return 1
    fi
  fi
  if [[ -z $self && -z $target || -n $self && -n $target ]]; then
    printf '"--self" and "--target" are exclusive\n'
    return 1
  fi
  printf '%s\n' "$target"
}
