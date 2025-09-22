#!/bin/bash
set -eou pipefail
function _main() {
  _SCRIPT_DIR="$_HOME/$_DOTS_DIR/$(dirname "$1")" && shift
  _CMD='' && [ "$#" -ge 1 ] && _CMD="$1"
  case $_CMD in

  configure) return 0 ;;

  setup)
    run_as_root stow "$_SCRIPT_DIR/layer-grub.conf" '/etc/default/grub'
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-bin-regenerate-bootloader.sh" "$_HOME/.local/bin/regenerate-bootloader"
    ;;

  *) return 1 ;;
  esac
}
_main "$@"
