#!/bin/bash
set -eou pipefail
function _main() {
  _SCRIPT_DIR="$_HOME/$_DOTS_DIR/$(dirname "$1")/files.d" && shift
  _CMD='' && [ "$#" -ge 1 ] && _CMD="$1"
  case $_CMD in

  configure) # configures system with dotfiles settings
    # wip
    run_as_user "$_USER" secrets-set gpg-github-pedro-pereira-dev
    run_as_user "$_USER" secrets-set ssh-gentoo-hetzner-media
    run_as_user "$_USER" secrets-set ssh-github-pedro-pereira-dev
    run_as_user "$_USER" secrets-set ssh-mercedes-github-pesoare
    run_as_user "$_USER" secrets-import
    return 0
    ;;

  setup) # links dotfiles settings into the system
    run_as_user "$_USER" stow "$_SCRIPT_DIR/homebrew-brewfile.conf" "$_HOME/Brewfile"
    return 0
    ;;
    # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

  *) return 1 ;; # handles unknown commands
  esac
}
_main "$@"
