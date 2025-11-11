#!/bin/sh
_HOST='bra-m0064'
_USER='pereiped'

configure() {
  source_file 'shared-base.d/shared-base.sh'
  source_file 'shared-code.d/shared-code.sh'
  source_file 'shared-desktop.d/shared-desktop.sh'

  run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/host-bra-m0064.d/confs/brewfile.conf" "$_HOME/Brewfile"
  run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/host-bra-m0064.d/confs/karabiner.json" "$_HOME/.config/karabiner/karabiner.json"
  run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/host-bra-m0064.d/confs/rectangle.json" "$_HOME/.config/rectangle/config.json"
  run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/host-bra-m0064.d/confs/ukelele-20251009/" "$_HOME/.config/ukelele/20251009"
  run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/host-bra-m0064.d/tools/" "$_HOME/.local/bin/"

  get_option '--full' "$@" && (
    run_as_user "$_USER" "$_HOME/.local/bin/brew-upgrade"
  ) || true
}
