#!/usr/bin/env bash
# shellcheck disable=SC1090

_execute_script() {
  local _mode=$1
  local _name=${2-}
  local _path
  local _paths=("$DOTS_DIR/$_name" "$DOTFILES_WORKSPACE/$_name" "/tmp/dotfiles/$_name")
  shift && [[ $# -gt 0 ]] && shift

  case $_mode in run | source) ;; *) return 1 ;; esac
  case $_name in '' | /* | . | .. | ./* | ../* | */. | */.. | */./* | */../*) return 1 ;; esac

  for _path in "${_paths[@]}"; do [[ -f $_path ]] && break; done
  [[ -f $_path ]] || return 1

  case $_mode in
  run) bash "$_path" "$@" ;;
  source) source "$_path" "$@" ;;
  esac
}

run_script() { _execute_script run "$@"; }
source_script() { _execute_script source "$@"; }
