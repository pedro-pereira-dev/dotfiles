#!/bin/sh
_HOSTNAME='gentoo-server-oracle'
_USER='chuck'

# configure() {
#   # dotfiles tooling
#   source_file 'dots.d/layer.sh'
#   # # base system settings
#   source_file 'shared-bash.d/layer.sh'
#   source_file 'shared-git.d/layer.sh'
#   source_file 'shared-secrets.d/layer.sh'
#   source_file 'shared-ssh.d/layer.sh'
#   # # code settings and tooling
#   source_file 'shared-lazygit.d/layer.sh'
#   source_file 'shared-neovim.d/layer.sh'
#   source_file 'shared-tmux.d/layer.sh'
#   # # desktop environment
#   source_file 'shared-alacritty.d/layer.sh'
#   # host specific settings
#   run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/host-bra-m0064.d/layer-bin-brew-upgrade.sh" "$_HOME/.local/bin/brew-upgrade"
#   run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/host-bra-m0064.d/layer-homebrew-brewfile.conf" "$_HOME/Brewfile"
#   run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/host-bra-m0064.d/layer-karabiner/" "$_HOME/.config/karabiner/"
#   run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/host-bra-m0064.d/layer-rectangle.json" "$_HOME/.config/rectangle/config.json"
#   run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/host-bra-m0064.d/layer-ukelele-20251009/" "$_HOME/.config/ukelele/20251009/"
#   run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/host-bra-m0064.d/layer-ukelele.zip" "$_HOME/.config/ukelele/ukelele.zip"
#   # updates dependencies
#   get_option '--full' "$@" && run_as_user "$_USER" "$_HOME/.local/bin/brew-upgrade" || true
# }

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
