#!/bin/bash
set -eou pipefail
function _main() {
  _SCRIPT_DIR="$_HOME/$_DOTS_DIR/$(dirname "$1")" && shift
  _CMD='' && [ "$#" -ge 1 ] && _CMD="$1"
  case $_CMD in

  configure) return 0 ;;

  setup)
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-bin-nvim-reloadable.sh" "$_HOME/.local/bin/nvim-reloadable"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-neovim-init.lua" "$_HOME/.config/nvim/init.lua"
    ;;

  *) return 1 ;;
  esac
}
_main "$@"
