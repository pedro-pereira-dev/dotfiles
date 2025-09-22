#!/bin/bash
set -eou pipefail
function _main() {
  _SCRIPT_DIR="$_HOME/$_DOTS_DIR/$(dirname "$1")" && shift
  _CMD='' && [ "$#" -ge 1 ] && _CMD="$1"
  case $_CMD in

  configure) return 0 ;;

  setup) # links dotfiles settings into the system
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-bin-secrets-bootstrap.sh" "$_HOME/.local/bin/secrets-bootstrap"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-bin-secrets-create.sh" "$_HOME/.local/bin/secrets-create"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-bin-secrets-import.sh" "$_HOME/.local/bin/secrets-import"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-bin-secrets-remove.sh" "$_HOME/.local/bin/secrets-remove"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-bin-secrets-set.sh" "$_HOME/.local/bin/secrets-set"

    return 0
    ;;
    # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

  *) return 1 ;; # handles unknown commands
  esac
}
_main "$@"
