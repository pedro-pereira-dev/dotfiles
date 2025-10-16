#!/bin/sh
_DEV='/dev/nvme0n1'
_HOST='gentoo-laptop-dell'
_USER='chuck'
_ROOT_SIZE='69001MiB' # 64gb

configure() {
  source_file 'shared-base.d/shared-base.sh'
  source_file 'shared-code.d/shared-code.sh'
  source_file 'shared-desktop.d/shared-desktop.sh'
  source_file 'gentoo-base.d/gentoo-base.sh'
  source_file 'gentoo-desktop.d/gentoo-desktop.sh'

  run_as_root stow "$_HOME/$_DOTS_DIR/host-gentoo-laptop-dell.d/gentoo-confs/" '/etc/portage/'
  run_as_root stow "$_HOME/$_DOTS_DIR/host-gentoo-laptop-dell.d/system-confs/dracut.conf" '/etc/dracut.conf.d/dracut.conf'
  run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/host-gentoo-laptop-dell.d/system-confs/ssh-gentoo-laptop.conf" "$_HOME/.ssh/config.d/gentoo-laptop"

  get_option '--full' "$@" && (
    run_as_root '/usr/bin/eauto' --unsupervised
    run_as_root eselect news read >/dev/null
    run_as_root '/usr/bin/regenerate-bootloader'
  ) || true

  run_as_root rc-update del agetty.tty2 default >/dev/null 2>&1 || true
  run_as_root rc-update del agetty.tty3 default >/dev/null 2>&1 || true
  run_as_root rc-update del agetty.tty4 default >/dev/null 2>&1 || true
  run_as_root rc-update del agetty.tty5 default >/dev/null 2>&1 || true
  run_as_root rc-update del agetty.tty6 default >/dev/null 2>&1 || true

  run_as_root rc-update add NetworkManager default >/dev/null 2>&1 || true
  run_as_root rc-update add power-profiles-daemon default >/dev/null 2>&1 || true

  run_as_root usermod --append --groups video "$_USER" # for backlight
  run_as_user "$_USER" "$_HOME/.local/bin/install-nerd-font" JetBrainsMono
}
