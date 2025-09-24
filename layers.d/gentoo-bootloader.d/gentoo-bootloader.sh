#!/bin/bash
set -eou pipefail
function _main() {
  _SCRIPT_DIR="$_HOME/$_DOTS_DIR/$(dirname "$1")" && shift
  _CMD='' && [ "$#" -ge 1 ] && _CMD="$1"
  case $_CMD in

  configure)
    if get_option "$_FULL_FLAG" "$@"; then
      run_as_root regenerate-bootloader
    fi
    return 0
    ;;

  setup)
    run_as_root stow "$_SCRIPT_DIR/layer-bin-regenerate-bootloader.sh" '/usr/bin/regenerate-bootloader'
    run_as_root stow "$_SCRIPT_DIR/layer-grub.conf" '/etc/default/grub'
    ;;

  *) return 1 ;;
  esac
}
_main "$@"
