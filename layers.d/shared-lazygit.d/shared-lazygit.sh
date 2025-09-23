#!/bin/bash
set -eou pipefail
function _main() {
  _SCRIPT_DIR="$_HOME/$_DOTS_DIR/$(dirname "$1")" && shift
  _CMD='' && [ "$#" -ge 1 ] && _CMD="$1"
  case $_CMD in

  configure) return 0 ;;

  setup)
    is_linux && run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-lazygit-config.yml" "$_HOME/.config/lazygit/config.yml"
    is_macos && run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-lazygit-config.yml" "$_HOME/Library/Application Support/lazygit/config.yml"
    ;;

  *) return 1 ;;
  esac
}
_main "$@"
