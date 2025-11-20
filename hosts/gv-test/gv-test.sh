#!/bin/sh
# shellcheck source=/dev/null
set -eou pipefail

_HOSTNAME=gv-test

configure() {
  { get_parameter --clean "$@" >/dev/null || get_parameter --full "$@" >/dev/null; } &&
    run_as_root find / -name '*' -type l 2>/dev/null | while IFS= read -r _LINK; do
      case $_LINK in /dev/* | /proc/* | /run/* | /sys/* | /tmp/*) continue ;; esac
      case $(find "$_LINK" -prune -printf '%l\n' 2>/dev/null)/ in
      "$_HOME/workspace/personal/dotfiles"/*) rm -v "$_LINK" &&
      find "$(dirname "$_LINK")" -depth -type d -empty -delete ;; esac
    done

  link_as_root "$_HOME/workspace/personal/dotfiles/dots.sh" /usr/bin/dots

  ! command -v doas >/dev/null && run_as_root emerge --ask=n -n app-admin/doas
  command -v doas >/dev/null &&
    run_as_root cp -f "$_HOME/workspace/personal/dotfiles/files/system-doas.conf" /etc/doas.conf &&
    run_as_root chown root:root /etc/doas.conf && run_as_root chmod 0600 /etc/doas.conf && run_as_root passwd -dl root >/dev/null

  run_as_root rc-update add sshd default >/dev/null

  return 0
}
