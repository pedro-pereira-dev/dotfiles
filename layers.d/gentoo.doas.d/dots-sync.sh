#!/bin/bash
set -eou pipefail
function _main() {
  _SCRIPT_DIR="$_HOME/$_DOTS_DIR/$(dirname "$1")" && shift
  _CMD='' && [ "$#" -ge 1 ] && _CMD="$1"
  case $_CMD in

  configure)
    ! check_command doas && echo '[I] installing doas...' &&
      run_as_root emerge --ask=n --noreplace app-admin/doas || true
    run_as_root cp -f "$_SCRIPT_DIR/layer-doas.conf" '/etc/doas.conf' &&
      run_as_root chmod 0600 /etc/doas.conf &&
      run_as_root chown root:root /etc/doas.conf &&
      run_as_root passwd -dl root >/dev/null 2>&1
    ;;

  setup) return 0 ;;

  *) return 1 ;;
  esac
}
_main "$@"
