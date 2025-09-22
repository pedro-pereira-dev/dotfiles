#!/bin/bash
set -eou pipefail
function _main() {
  _SCRIPT_DIR="$_HOME/$_DOTS_DIR/$(dirname "$1")" && shift
  _CMD='' && [ "$#" -ge 1 ] && _CMD="$1"
  case $_CMD in

  configure) # configures system with dotfiles settings
    # installs doas package
    ! check_command doas && echo '[I] installing doas...' &&
      run_as_root emerge --ask=n --noreplace app-admin/doas || true
    # configures doas
    run_as_root cp -f "$_SCRIPT_DIR/doas-configuration.conf" '/etc/doas.conf' &&
      run_as_root chmod 0600 /etc/doas.conf &&
      run_as_root chown root:root /etc/doas.conf &&
      run_as_root passwd -dl root >/dev/null 2>&1
    return 0
    ;;

  setup) # links dotfiles settings into the system
    run_as_root stow "$_SCRIPT_DIR/layer-grub-config.conf" '/etc/default/grub'
    run_as_root stow "$_SCRIPT_DIR/layer-portage-overlays.conf" '/etc/portage/repos.conf/overlays.conf'
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-bin-portage-eauto.sh" "$_HOME/.local/bin/eauto"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-bin-portage-edeclare.sh" "$_HOME/.local/bin/edeclare"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-bin-portage-edelete.sh" "$_HOME/.local/bin/edelete"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-bin-portage-eupdate.sh" "$_HOME/.local/bin/eupdate"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-bin-portage-eupgrade.sh" "$_HOME/.local/bin/eupgrade"
    run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-bin-system-regenerate-bootloader.sh" "$_HOME/.local/bin/regenerate-bootloader"
    return 0
    ;;
    # ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----

  *) return 1 ;; # handles unknown commands
  esac
}
_main "$@"
