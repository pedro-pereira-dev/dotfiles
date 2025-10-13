#!/bin/sh
# ! check_command doas && echo '[I] installing doas...' &&
#   run_as_root emerge --ask=n --noreplace app-admin/doas || true
# check_command doas &&
#   run_as_root cp -f "$_SCRIPT_DIR/layer-doas.conf" '/etc/doas.conf' &&
#   run_as_root chmod 0600 /etc/doas.conf &&
#   run_as_root chown root:root /etc/doas.conf &&
#   run_as_root passwd -dl root >/dev/null 2>&1
