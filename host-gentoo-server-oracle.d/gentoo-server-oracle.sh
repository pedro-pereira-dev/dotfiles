#!/bin/sh
_HOSTNAME='gentoo-server-oracle'
_USER='chuck'

configure() {
  source_file 'shared-base.d/shared-base.sh'
  source_file 'gentoo-base.d/gentoo-base.sh'
  source_file 'gentoo-server.d/gentoo-server.sh'

  run_as_root stow "$_HOME/$_DOTS_DIR/host-gentoo-server-oracle.d/gentoo-confs/" "/etc/portage/"
  run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/host-gentoo-server-oracle.d/podman-confs/" "$_HOME/.podman/"
}

# #!/bin/bash
# set -eou pipefail
# function _main() {
#   _SCRIPT_DIR="$_HOME/$_DOTS_DIR/$(dirname "$1")" && shift
#   _CMD='' && [ "$#" -ge 1 ] && _CMD="$1"
#   case $_CMD in
#
#   configure)
#     if get_option "$_FULL_FLAG" "$@"; then
#       run_as_user "$_USER" "$_HOME/.local/bin/secrets-set" gpg-github-pedro-pereira-dev
#       run_as_user "$_USER" "$_HOME/.local/bin/secrets-set" ssh-github-pedro-pereira-dev
#       run_as_user "$_USER" "$_HOME/.local/bin/secrets-import"
#     fi
#     run_as_root rc-update add sshd default >/dev/null 2>&1
#     return 0
#     ;;
#
#   setup)
#     run_as_root stow "$_SCRIPT_DIR/layer-hwclock.conf" '/etc/conf.d/hwclock'
#     run_as_root stow "$_SCRIPT_DIR/layer-podman-kernel-module-ip-tables.conf" '/etc/modules-load.d/ip-tables.conf'
#     run_as_root stow "$_SCRIPT_DIR/layer-podman-sshd-gateway-ports.conf" '/etc/ssh/sshd_config.d/gateway-ports.conf'
#     run_as_root stow "$_SCRIPT_DIR/layer-podman-unprivileged-port-start.conf" '/etc/sysctl.d/unprivileged-port-start.conf'
#     run_as_root stow "$_SCRIPT_DIR/layer-portage-accept-keywords.conf" '/etc/portage/package.accept_keywords'
#     # run_as_root stow "$_SCRIPT_DIR/layer-portage-make.conf" '/etc/portage/make.conf'
#     run_as_root stow "$_SCRIPT_DIR/layer-portage-package-declare.conf" '/etc/portage/package.declare'
#     run_as_root stow "$_SCRIPT_DIR/layer-portage-package-license.conf" '/etc/portage/package.license'
#     run_as_root stow "$_SCRIPT_DIR/layer-portage-package-mask.conf" '/etc/portage/package.mask'
#     run_as_root stow "$_SCRIPT_DIR/layer-portage-package-unmask.conf" '/etc/portage/package.unmask'
#     run_as_root stow "$_SCRIPT_DIR/layer-portage-package-use.conf" '/etc/portage/package.use'
#     run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-podman-gentoo-server-hetzner-proxy-compose.yaml" "$_HOME/.podman/compose.yaml"
#     run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-podman-haproxy.cfg" "$_HOME/.podman/haproxy.cfg"
#     run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-remote-4620-duckdns-org-pem.enc" "$_HOME/.podman/remote-4620.duckdns.org.pem"
#     return 0
#     ;;
#
#   *) return 1 ;;
#   esac
# }
# _main "$@"
