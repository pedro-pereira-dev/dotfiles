#!/bin/sh
run_as_root stow "$_HOME/$_DOTS_DIR/gentoo-base.d/gentoo-tools/" '/usr/bin/'
run_as_root stow "$_HOME/$_DOTS_DIR/gentoo-base.d/system-confs/grub.conf" '/etc/default/grub'
run_as_root stow "$_HOME/$_DOTS_DIR/gentoo-base.d/system-confs/overlays.conf" '/etc/portage/repos.conf/overlays.conf'
run_as_root stow "$_HOME/$_DOTS_DIR/gentoo-base.d/system-confs/package.mask" '/etc/portage/'

! check_command doas && run_as_root emerge --ask=n --noreplace app-admin/doas || true
check_command doas &&
  run_as_root cp -f "$_HOME/$_DOTS_DIR/gentoo-base.d/system-confs/doas.conf" '/etc/doas.conf' &&
  run_as_root chmod 0600 /etc/doas.conf &&
  run_as_root chown root:root /etc/doas.conf &&
  run_as_root passwd -dl root >/dev/null 2>&1

# if get_option "$_FULL_FLAG" "$@"; then
#   run_as_root "$_HOME/.local/bin/regenerate-bootloader"
# fi
# run_as_root rc-update del agetty.tty2 default >/dev/null 2>&1
# run_as_root rc-update del agetty.tty3 default >/dev/null 2>&1
# run_as_root rc-update del agetty.tty4 default >/dev/null 2>&1
# run_as_root rc-update del agetty.tty5 default >/dev/null 2>&1
# run_as_root rc-update del agetty.tty6 default >/dev/null 2>&1

# if get_option "$_FULL_FLAG" "$@" || get_option "$_INSTALL_FLAG" "$@"; then
#   run_as_root "/usr/bin/eupdate"
#   run_as_root "/usr/bin/eupgrade" --unsupervised
#   run_as_root "/usr/bin/edeclare" --unsupervised
#   run_as_root "/usr/bin/edelete" --unsupervised
#   run_as_root eselect news read >/dev/null
# fi
