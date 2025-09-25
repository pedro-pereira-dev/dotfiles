#!/bin/bash
set -eou pipefail
function _main() {
  _SCRIPT_DIR="$_HOME/$_DOTS_DIR/$(dirname "$1")" && shift
  _CMD='' && [ "$#" -ge 1 ] && _CMD="$1"
  case $_CMD in

  configure)
    if get_option "$_FULL_FLAG" "$@" || get_option "$_INSTALL_FLAG" "$@"; then
      run_as_user "$_USER" "$_HOME/.local/bin/brew-upgrade"
    fi
    # if get_option "$_FULL_FLAG" "$@"; then
    #   run_as_user "$_USER" secrets-set gpg-github-pedro-pereira-dev
    #   run_as_user "$_USER" secrets-set ssh-authorized-keys
    #   run_as_user "$_USER" secrets-set ssh-gentoo-hetzner-media
    #   run_as_user "$_USER" secrets-set ssh-gentoo-laptop
    #   run_as_user "$_USER" secrets-set ssh-github-pedro-pereira-dev
    #   run_as_user "$_USER" secrets-set ssh-mercedes-github-pesoare
    #   run_as_user "$_USER" secrets-import
    # fi
    return 0
    ;;

  setup)
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-bin-brew-upgrade.sh" "$_HOME/.local/bin/brew-upgrade"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-homebrew-brewfile.conf" "$_HOME/Brewfile"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-karabiner.json" "$_HOME/.config/karabiner/karabiner.json"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-rectangle.json" "$_HOME/.config/rectangle/rectangle.json"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-ukelele.zip" "$_HOME/.config/ukelele/ukelele.zip"
    return 0
    ;;

  *) return 1 ;;
  esac
}
_main "$@"
