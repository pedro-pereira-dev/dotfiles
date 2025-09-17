#!/bin/bash
set -eou pipefail

_SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# symlinks dotfiles files to target system
run_as_root stow "$_SCRIPT_DIR/portage-overlays.conf" /etc/portage/repos.conf/overlays.conf

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# wip
run_as_root cat <<EOF >/etc/doas.conf
permit persist  :wheel
permit nopass   :wheel as root  cmd reboot
permit nopass   :wheel as root  cmd shutdown
EOF
[ -f /etc/doas.conf ] &&
  run_as_root chmod 0600 /etc/doas.conf &&
  run_as_root chown root:root /etc/doas.conf &&
  run_as_root passwd -dl root >/dev/null 2>&1
