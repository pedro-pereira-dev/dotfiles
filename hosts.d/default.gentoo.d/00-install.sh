#!/bin/bash
set -eou pipefail

_HOME="$(get_home "$@")" && _USER="$(get_user "$@")"
_SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# symlinks dotfiles files to target system
run_as_root stow "$_SCRIPT_DIR/portage-overlays.conf" '/etc/portage/repos.conf/overlays.conf'
run_as_user "$_USER" stow "$_SCRIPT_DIR/bin-portage-eauto.sh" "$_HOME/.local/bin/eauto"
run_as_user "$_USER" stow "$_SCRIPT_DIR/bin-portage-edeclare.sh" "$_HOME/.local/bin/edeclare"
run_as_user "$_USER" stow "$_SCRIPT_DIR/bin-portage-edelete.sh" "$_HOME/.local/bin/edelete"
run_as_user "$_USER" stow "$_SCRIPT_DIR/bin-portage-eupdate.sh" "$_HOME/.local/bin/eupdate"
run_as_user "$_USER" stow "$_SCRIPT_DIR/bin-portage-eupgrade.sh" "$_HOME/.local/bin/eupgrade"
run_as_user "$_USER" stow "$_SCRIPT_DIR/bin-system-regenerate-bootloader.sh" "$_HOME/.local/bin/regenerate-bootloader"

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# wip
! check_command doas &&
  echo '[I] installing doas...' &&
  run_as_root emerge --ask=n --noreplace app-admin/doas
run_as_root cat <<EOF >/etc/doas.conf
permit persist  :wheel
permit nopass   :wheel as root  cmd reboot
permit nopass   :wheel as root  cmd shutdown
EOF
check_command doas && [ -f /etc/doas.conf ] &&
  run_as_root chmod 0600 /etc/doas.conf &&
  run_as_root chown root:root /etc/doas.conf &&
  run_as_root passwd -dl root >/dev/null 2>&1
