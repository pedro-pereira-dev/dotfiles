#!/bin/bash
set -eou pipefail
function _main() {
  _SCRIPT_DIR="$_HOME/$_DOTS_DIR/$(dirname "$1")/files.d" && shift
  _CMD='' && [ "$#" -ge 1 ] && _CMD="$1"
  case $_CMD in

  configure) return 0 ;;

  setup) # links dotfiles settings into the system
    run_as_user "$_USER" stow "$_SCRIPT_DIR/bin-code.sh" "$_HOME/.local/bin/code"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/bin-nvim-reloadable.sh" "$_HOME/.local/bin/nvim-reloadable"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/lazygit.config.yml" "$_HOME/.config/lazygit/config.yml"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/neovim-config.lua" "$_HOME/.config/nvim/init.lua"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/tmux-config.conf" "$_HOME/.config/tmux/tmux.conf"

    return 0
    ;;
    # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

  *) return 1 ;; # handles unknown commands
  esac
}
_main "$@"
