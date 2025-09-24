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
    run_as_root rc-update del agetty.tty2 default >/dev/null 2>&1
    run_as_root rc-update del agetty.tty3 default >/dev/null 2>&1
    run_as_root rc-update del agetty.tty4 default >/dev/null 2>&1
    run_as_root rc-update del agetty.tty5 default >/dev/null 2>&1
    run_as_root rc-update del agetty.tty6 default >/dev/null 2>&1
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
