#!/bin/sh
_DEV='/dev/sda'
_HOSTNAME='gentoo-server-hetzner-proxy'
_USER='chuck'

configure() {
  source_file 'shared-base.d/shared-base.sh'
  source_file 'gentoo-base.d/gentoo-base.sh'

  run_as_root stow "$_HOME/$_DOTS_DIR/host-gentoo-server-hetzner-proxy.d/confs/gentoo-server-hetzner-proxy-declare.conf" '/etc/portage/package.declare/gentoo-server-hetzner-proxy-declare.conf'
  run_as_root stow "$_HOME/$_DOTS_DIR/host-gentoo-server-hetzner-proxy.d/confs/gentoo-server-hetzner-proxy-keywords.conf" '/etc/portage/package.accept_keywords/gentoo-server-hetzner-proxy-keywords.conf'
  run_as_root stow "$_HOME/$_DOTS_DIR/host-gentoo-server-hetzner-proxy.d/confs/gentoo-server-hetzner-proxy-license.conf" '/etc/portage/package.license/gentoo-server-hetzner-proxy-license.conf'
  run_as_root stow "$_HOME/$_DOTS_DIR/host-gentoo-server-hetzner-proxy.d/confs/gentoo-server-hetzner-proxy-unmask.conf" '/etc/portage/package.unmask/gentoo-server-hetzner-proxy-unmask.conf'
  run_as_root stow "$_HOME/$_DOTS_DIR/host-gentoo-server-hetzner-proxy.d/confs/gentoo-server-hetzner-proxy-use.conf" '/etc/portage/package.use/gentoo-server-hetzner-proxy-use.conf'
  run_as_root stow "$_HOME/$_DOTS_DIR/host-gentoo-server-hetzner-proxy.d/confs/hwclock.conf" '/etc/conf.d/hwclock'

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

  run_as_root rc-update add sshd default >/dev/null 2>&1 || true
}

# run_as_root stow "$_SCRIPT_DIR/layer-podman-sshd-gateway-ports.conf" '/etc/ssh/sshd_config.d/gateway-ports.conf'
# run_as_root stow "$_SCRIPT_DIR/layer-podman-unprivileged-port-start.conf" '/etc/sysctl.d/unprivileged-port-start.conf'
