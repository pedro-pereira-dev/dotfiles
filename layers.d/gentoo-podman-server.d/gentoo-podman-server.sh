#!/bin/bash
set -eou pipefail
function _main() {
  _SCRIPT_DIR="$_HOME/$_DOTS_DIR/$(dirname "$1")" && shift
  _CMD='' && [ "$#" -ge 1 ] && _CMD="$1"
  case $_CMD in

  configure)
    return 0
    ;;

  setup)
    # run_as_root stow "$_SCRIPT_DIR/layer-podman-compose-service.sh" '/etc/init.d/podman-compose'
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-compose.yaml" "$_HOME/.podman/compose.yaml"
    return 0
    ;;

  *) return 1 ;;
  esac
}
_main "$@"
