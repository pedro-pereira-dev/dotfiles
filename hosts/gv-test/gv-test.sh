#!/bin/sh
# shellcheck source=/dev/null
set -eou pipefail

_HOSTNAME=gv-test

configure() {
  { get_parameter --clean "$@" >/dev/null || get_parameter --full "$@" >/dev/null; } &&
    run_as_root find / -name '*' -type l 2>/dev/null | while IFS= read -r _LINK; do
      case $_LINK in /dev/* | /proc/* | /run/* | /sys/* | /tmp/*) continue ;; esac
      case $(find "$_LINK" -prune -printf '%l\n' 2>/dev/null)/ in
      "$_HOME/workspace/personal/dotfiles"/*) rm -v "$_LINK" ;; esac
    done

  link_as_root "$_HOME/workspace/personal/dotfiles/dots.sh" /usr/bin/dots

  ! command -v doas >/dev/null && run_as_root emerge --ask=n -n app-admin/doas
  command -v doas >/dev/null &&
    run_as_root cp -f "$_HOME/workspace/personal/dotfiles/files/system-doas.conf" /etc/doas.conf &&
    run_as_root chown root:root /etc/doas.conf && run_as_root chmod 0600 /etc/doas.conf && run_as_root passwd -dl root >/dev/null

  link_as_root "$_HOME/workspace/personal/dotfiles/files/portage-eauto.sh" /usr/bin/eauto
  link_as_root "$_HOME/workspace/personal/dotfiles/files/portage-edeclare.sh" /usr/bin/edeclare
  link_as_root "$_HOME/workspace/personal/dotfiles/files/portage-edelete.sh" /usr/bin/edelete
  link_as_root "$_HOME/workspace/personal/dotfiles/files/portage-eupdate.sh" /usr/bin/eupdate
  link_as_root "$_HOME/workspace/personal/dotfiles/files/portage-eupgrade.sh" /usr/bin/eupgrade
  link_as_root "$_HOME/workspace/personal/dotfiles/files/portage-overlays.conf" /etc/portage/repos.conf/overlays.conf
  link_as_root "$_HOME/workspace/personal/dotfiles/files/portage-package-mask.conf" /etc/portage/package.mask
  link_as_root "$_HOME/workspace/personal/dotfiles/files/system-grub.conf" /etc/default/grub

  link_as_root "$_HOME/workspace/personal/dotfiles/hosts/gv-test/gv-test-portage-package-declare.conf" /etc/portage/package.declare
  link_as_root "$_HOME/workspace/personal/dotfiles/hosts/gv-test/gv-test-portage-package-license.conf" /etc/portage/package.license
  link_as_root "$_HOME/workspace/personal/dotfiles/hosts/gv-test/gv-test-portage-package-use.conf" /etc/portage/package.use

  { get_parameter --install "$@" >/dev/null || get_parameter --full "$@" >/dev/null; } && {
    run_as_root /usr/bin/eauto --unattended
    run_as_root /usr/bin/installkernel -a
    run_as_root eselect news read --quiet all
  }

  run_as_root rc-update add sshd default >/dev/null

  run_as_root rc-update del agetty.tty1 default >/dev/null 2>&1
  run_as_root rc-update del agetty.tty2 default >/dev/null 2>&1
  run_as_root rc-update del agetty.tty3 default >/dev/null 2>&1
  run_as_root rc-update del agetty.tty4 default >/dev/null 2>&1
  run_as_root rc-update del agetty.tty5 default >/dev/null 2>&1
  run_as_root rc-update del agetty.tty6 default >/dev/null 2>&1

  return 0
}
