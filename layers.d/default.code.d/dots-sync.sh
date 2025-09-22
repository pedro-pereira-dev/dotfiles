#!/bin/bash
set -eou pipefail
function _main() {
  _SCRIPT_DIR="$_HOME/$_DOTS_DIR/$(dirname "$1")" && shift
  _CMD='' && [ "$#" -ge 1 ] && _CMD="$1"
  case $_CMD in

  configure) return 0 ;;

  setup) # links dotfiles settings into the system
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-bin-code.sh" "$_HOME/.local/bin/code"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-bin-nvim-reloadable.sh" "$_HOME/.local/bin/nvim-reloadable"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-neovim-config.lua" "$_HOME/.config/nvim/init.lua"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-tmux-config.conf" "$_HOME/.config/tmux/tmux.conf"
    # sets up arch dependent configuration
    is_linux && run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-lazygit.config.yml" "$_HOME/.config/lazygit/config.yml"
    is_macos && run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-lazygit.config.yml" "$_HOME/Library/Application Support/lazygit/config.yml"
    return 0
    ;;
    # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

  *) return 1 ;; # handles unknown commands
  esac
}
_main "$@"
