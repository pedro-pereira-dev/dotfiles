#!/bin/bash
set -eou pipefail

_HOME="$(get_home "$@")" && _USER="$(get_user "$@")"
_SCRIPT_DIR="$_HOME/$_DOTS_DIR/hosts.d/host.gentoo-laptop-dell.d"

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# symlinks dotfiles files to target system
run_as_root stow "$_SCRIPT_DIR/dracut-config.conf" '/etc/dracut.conf.d/dracut.conf'
run_as_root stow "$_SCRIPT_DIR/grub-config.conf" '/etc/default/grub'
run_as_root stow "$_SCRIPT_DIR/portage-accept-keywords.conf" '/etc/portage/package.accept_keywords'
run_as_root stow "$_SCRIPT_DIR/portage-make.conf" '/etc/portage/make.conf'
run_as_root stow "$_SCRIPT_DIR/portage-package-declare.conf" '/etc/portage/package.declare'
run_as_root stow "$_SCRIPT_DIR/portage-package-license.conf" '/etc/portage/package.license'
run_as_root stow "$_SCRIPT_DIR/portage-package-mask.conf" '/etc/portage/package.mask'
run_as_root stow "$_SCRIPT_DIR/portage-package-unmask.conf" '/etc/portage/package.unmask'
run_as_root stow "$_SCRIPT_DIR/portage-package-use.conf" '/etc/portage/package.use'
run_as_user "$_USER" stow "$_SCRIPT_DIR/bin-backlight-down.sh" "$_HOME/.local/bin/backlight-down"
run_as_user "$_USER" stow "$_SCRIPT_DIR/bin-backlight-up.sh" "$_HOME/.local/bin/backlight-up"
run_as_user "$_USER" stow "$_SCRIPT_DIR/bin-microphone-toggle.sh" "$_HOME/.local/bin/microphone-toggle"
run_as_user "$_USER" stow "$_SCRIPT_DIR/bin-volume-down.sh" "$_HOME/.local/bin/volume-down"
run_as_user "$_USER" stow "$_SCRIPT_DIR/bin-volume-toggle.sh" "$_HOME/.local/bin/volume-toggle"
run_as_user "$_USER" stow "$_SCRIPT_DIR/bin-volume-up.sh" "$_HOME/.local/bin/volume-up"
run_as_user "$_USER" stow "$_SCRIPT_DIR/gtk-config.toml" "$_HOME/.config/gtk-3.0/settings.ini"
run_as_user "$_USER" stow "$_SCRIPT_DIR/gtk-config.toml" "$_HOME/.config/gtk-4.0/settings.ini"
run_as_user "$_USER" stow "$_SCRIPT_DIR/ssh-gentoo-laptop.conf" "$_HOME/.ssh/config.d/gentoo-laptop.conf"
run_as_user "$_USER" stow "$_SCRIPT_DIR/sway-config.conf" "$_HOME/.config/sway/config"

# wip
! check_command nmtui && (
  true &&
    echo '[I] installing network manager...' &&
    run_as_root emerge --ask=n --noreplace net-misc/networkmanager &&
    run_as_root rc-update add NetworkManager default >/dev/null 2>&1
) || true

# rc-update add NetworkManager default >/dev/null 2>&1
# rc-update add power-profiles-daemon default >/dev/null 2>&1
# emerge -1 cpuid2cpuflags
# echo "*/* $(cpuid2cpuflags)" > file
