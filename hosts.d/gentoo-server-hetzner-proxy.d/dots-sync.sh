#!/bin/bash
set -eou pipefail
function _main() {
  _SCRIPT_DIR="$_HOME/$_DOTS_DIR/$(dirname "$1")" && shift
  _CMD='' && [ "$#" -ge 1 ] && _CMD="$1"
  case $_CMD in

  configure) return 0 ;;

  setup) # links dotfiles settings into the system
    run_as_root stow "$_SCRIPT_DIR/layer-portage-accept-keywords.conf" '/etc/portage/package.accept_keywords'
    run_as_root stow "$_SCRIPT_DIR/layer-portage-make.conf" '/etc/portage/make.conf'
    run_as_root stow "$_SCRIPT_DIR/layer-portage-package-declare.conf" '/etc/portage/package.declare'
    run_as_root stow "$_SCRIPT_DIR/layer-portage-package-license.conf" '/etc/portage/package.license'
    run_as_root stow "$_SCRIPT_DIR/layer-portage-package-mask.conf" '/etc/portage/package.mask'
    run_as_root stow "$_SCRIPT_DIR/layer-portage-package-unmask.conf" '/etc/portage/package.unmask'
    run_as_root stow "$_SCRIPT_DIR/layer-portage-package-use.conf" '/etc/portage/package.use'
    return 0
    ;;
    # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

  *) return 1 ;; # handles unknown commands
  esac
}
_main "$@"
