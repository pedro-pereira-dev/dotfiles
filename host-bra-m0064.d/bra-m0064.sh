#!/bin/sh
_HOST='bra-m0064'
_USER='pereiped'

configure() {
  # dotfiles tooling
  source_file 'dots.d/layer.sh'
  source_file 'shared-base.d/shared-base.sh'
  source_file 'shared-code.d/shared-code.sh'
  # # base system settings
  # source_file 'shared-bash.d/layer.sh'
  # source_file 'shared-git.d/layer.sh'
  # source_file 'shared-secrets.d/layer.sh'
  # source_file 'shared-ssh.d/layer.sh'
  # # code settings and tooling
  # source_file 'shared-lazygit.d/layer.sh'
  # source_file 'shared-neovim.d/layer.sh'
  # source_file 'shared-tmux.d/layer.sh'
  # # desktop environment
  # source_file 'shared-alacritty.d/layer.sh'
  # host specific settings
  run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/host-bra-m0064.d/layer-bin-brew-upgrade.sh" "$_HOME/.local/bin/brew-upgrade"
  run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/host-bra-m0064.d/layer-homebrew-brewfile.conf" "$_HOME/Brewfile"
  run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/host-bra-m0064.d/layer-karabiner/" "$_HOME/.config/karabiner/"
  run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/host-bra-m0064.d/layer-rectangle.json" "$_HOME/.config/rectangle/config.json"
  run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/host-bra-m0064.d/layer-ukelele-20251009/" "$_HOME/.config/ukelele/20251009/"
  run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/host-bra-m0064.d/layer-ukelele.zip" "$_HOME/.config/ukelele/ukelele.zip"
  # updates dependencies
  get_option '--full' "$@" && run_as_user "$_USER" "$_HOME/.local/bin/brew-upgrade" || true
}

# #!/bin/bash
# set -eou pipefail
# function _main() {
#   _SCRIPT_DIR="$_HOME/$_DOTS_DIR/$(dirname "$1")" && shift
#   _CMD='' && [ "$#" -ge 1 ] && _CMD="$1"
#   case $_CMD in
#
#   configure)
#     if get_option "$_FULL_FLAG" "$@" || get_option "$_INSTALL_FLAG" "$@"; then
#       run_as_user "$_USER" "$_HOME/.local/bin/brew-upgrade"
#     fi
#     # if get_option "$_FULL_FLAG" "$@"; then
#     #   run_as_user "$_USER" secrets-set gpg-github-pedro-pereira-dev
#     #   run_as_user "$_USER" secrets-set ssh-authorized-keys
#     #   run_as_user "$_USER" secrets-set ssh-gentoo-hetzner-media
#     #   run_as_user "$_USER" secrets-set ssh-gentoo-laptop
#     #   run_as_user "$_USER" secrets-set ssh-github-pedro-pereira-dev
#     #   run_as_user "$_USER" secrets-set ssh-mercedes-github-pesoare
#     #   run_as_user "$_USER" secrets-import
#     # fi
#     return 0
#     ;;
#
#   setup)
#     run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-bin-brew-upgrade.sh" "$_HOME/.local/bin/brew-upgrade"
#     run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-homebrew-brewfile.conf" "$_HOME/Brewfile"
#     run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-karabiner/" "$_HOME/.config/karabiner/"
#     run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-rectangle.json" "$_HOME/.config/rectangle/config.json"
#     run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-ukelele-20251009/" "$_HOME/.config/ukelele/20251009/"
#     run_as_user "$_USER" stow "$_SCRIPT_DIR/layer-ukelele.zip" "$_HOME/.config/ukelele/ukelele.zip"
#     return 0
#     ;;
#
#   *) return 1 ;;
#   esac
# }
# _main "$@"
