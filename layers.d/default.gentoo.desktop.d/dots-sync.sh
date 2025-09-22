#!/bin/bash
set -eou pipefail
function _main() {
  _SCRIPT_DIR="$_HOME/$_DOTS_DIR/$(dirname "$1")" && shift
  _CMD='' && [ "$#" -ge 1 ] && _CMD="$1"
  case $_CMD in

  configure) return 0 ;;

  setup) # links dotfiles settings into the system
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-bin-backlight-down.sh" "$_HOME/.local/bin/backlight-down"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-bin-backlight-up.sh" "$_HOME/.local/bin/backlight-up"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-bin-microphone-toggle.sh" "$_HOME/.local/bin/microphone-toggle"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-bin-volume-down.sh" "$_HOME/.local/bin/volume-down"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-bin-volume-toggle.sh" "$_HOME/.local/bin/volume-toggle"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-bin-volume-up.sh" "$_HOME/.local/bin/volume-up"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-gtk-config.toml" "$_HOME/.config/gtk-3.0/settings.ini"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-gtk-config.toml" "$_HOME/.config/gtk-4.0/settings.ini"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-sway-config.conf" "$_HOME/.config/sway/config"
    return 0
    ;;
    # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

  *) return 1 ;; # handles unknown commands
  esac
}
_main "$@"
