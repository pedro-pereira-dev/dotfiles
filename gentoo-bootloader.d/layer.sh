#!/bin/sh
run_as_root stow "$_HOME/$_DOTS_DIR/gentoo-bootloader.d/layer-bin-regenerate-bootloader.sh" "$_HOME/.local/bin/regenerate-bootloader"
run_as_root stow "$_HOME/$_DOTS_DIR/gentoo-bootloader.d/layer-grub.conf" '/etc/default/grub'

# if get_option "$_FULL_FLAG" "$@"; then
#   run_as_root "$_HOME/.local/bin/regenerate-bootloader"
# fi
# run_as_root rc-update del agetty.tty2 default >/dev/null 2>&1
# run_as_root rc-update del agetty.tty3 default >/dev/null 2>&1
# run_as_root rc-update del agetty.tty4 default >/dev/null 2>&1
# run_as_root rc-update del agetty.tty5 default >/dev/null 2>&1
# run_as_root rc-update del agetty.tty6 default >/dev/null 2>&1
