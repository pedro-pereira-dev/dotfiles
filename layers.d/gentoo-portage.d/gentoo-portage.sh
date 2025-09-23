#!/bin/bash
set -eou pipefail
function _main() {
  _SCRIPT_DIR="$_HOME/$_DOTS_DIR/$(dirname "$1")" && shift
  _CMD='' && [ "$#" -ge 1 ] && _CMD="$1"
  case $_CMD in

  configure) return 0 ;;

  setup)
    run_as_root stow "$_SCRIPT_DIR/layer-bin-portage-eauto.sh" '/usr/bin/eauto'
    run_as_root stow "$_SCRIPT_DIR/layer-bin-portage-edeclare.sh" '/usr/bin/edeclare'
    run_as_root stow "$_SCRIPT_DIR/layer-bin-portage-edelete.sh" '/usr/bin/edelete'
    run_as_root stow "$_SCRIPT_DIR/layer-bin-portage-eupdate.sh" '/usr/bin/eupdate'
    run_as_root stow "$_SCRIPT_DIR/layer-bin-portage-eupgrade.sh" '/usr/bin/eupgrade'
    run_as_root stow "$_SCRIPT_DIR/layer-portage-overlays.conf" '/etc/portage/repos.conf/overlays.conf'
    run_as_root stow "$_SCRIPT_DIR/layer-portage-package-mask.conf" '/etc/portage/package.mask'
    return 0
    ;;

  *) return 1 ;;
  esac
}
_main "$@"
