#!/bin/bash
set -eou pipefail
function _main() {
  _SCRIPT_DIR="$_HOME/$_DOTS_DIR/$(dirname "$1")" && shift
  _CMD='' && [ "$#" -ge 1 ] && _CMD="$1"
  case $_CMD in

  configure) return 0 ;;

  setup)
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-gitconfig-default.conf" "$_HOME/.gitconfig.default"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-gitconfig-mercedes.conf" "$_HOME/.gitconfig.mercedes"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-gitconfig.conf" "$_HOME/.gitconfig"
    return 0
    ;;

  *) return 1 ;;
  esac
}
_main "$@"
