#!/bin/bash
set -eou pipefail
function _main() {
  _SCRIPT_DIR="$_HOME/$_DOTS_DIR/$(dirname "$1")" && shift
  _CMD='' && [ "$#" -ge 1 ] && _CMD="$1"
  case $_CMD in

  configure)
    if get_option "$_FULL_FLAG" "$@"; then
      run_as_user "$_USER" "$_HOME/.local/bin/secrets-set" gpg-github-pedro-pereira-dev
      run_as_user "$_USER" "$_HOME/.local/bin/secrets-set" ssh-github-pedro-pereira-dev
      run_as_user "$_USER" "$_HOME/.local/bin/secrets-import"
    fi
    run_as_root rc-update add sshd default >/dev/null 2>&1
    return 0
    ;;

  setup)
    run_as_root stow "$_SCRIPT_DIR/layer-portage-accept-keywords.conf" '/etc/portage/package.accept_keywords'
    run_as_root stow "$_SCRIPT_DIR/layer-portage-package-declare.conf" '/etc/portage/package.declare'
    run_as_root stow "$_SCRIPT_DIR/layer-portage-package-license.conf" '/etc/portage/package.license'
    run_as_root stow "$_SCRIPT_DIR/layer-portage-package-mask.conf" '/etc/portage/package.mask'
    run_as_root stow "$_SCRIPT_DIR/layer-portage-package-unmask.conf" '/etc/portage/package.unmask'
    run_as_root stow "$_SCRIPT_DIR/layer-portage-package-use.conf" '/etc/portage/package.use'
    return 0
    ;;

  *) return 1 ;;
  esac
}
_main "$@"
