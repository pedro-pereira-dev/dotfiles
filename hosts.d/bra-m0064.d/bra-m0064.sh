#!/bin/bash
set -eou pipefail
function _main() {
  _SCRIPT_DIR="$_HOME/$_DOTS_DIR/$(dirname "$1")" && shift
  _CMD='' && [ "$#" -ge 1 ] && _CMD="$1"
  case $_CMD in

  configure)
    (get_option "$_FULL_FLAG" "$@" || get_option "$_INSTALL_FLAG" "$@") &&
      run_as_user "$_USER" brew-upgrade
    # wip
    # run_as_user "$_USER" secrets-set gpg-github-pedro-pereira-dev
    # run_as_user "$_USER" secrets-set ssh-gentoo-hetzner-media
    # run_as_user "$_USER" secrets-set ssh-github-pedro-pereira-dev
    # run_as_user "$_USER" secrets-set ssh-mercedes-github-pesoare
    # run_as_user "$_USER" secrets-import
    return 0
    ;;

  setup)
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-homebrew-brewfile.conf" "$_HOME/Brewfile"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-bin-brew-upgrade.sh" "$_HOME/.local/bin/brew-upgrade"
    ;;

  *) return 1 ;;
  esac
}
_main "$@"
