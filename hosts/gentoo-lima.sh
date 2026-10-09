#!/usr/bin/env bash
# shellcheck disable=SC2154
set -euo pipefail

dots_pull() {
  install_gentoo_git
  maintain_dotfiles
}

dots_sync() {

  link_file "$DOTFILES_WORKSPACE/bin/eauto" "$HOME/.local/bin/eauto"
  link_file "$DOTFILES_WORKSPACE/bin/edeclare" "$HOME/.local/bin/edeclare"
  link_file "$DOTFILES_WORKSPACE/bin/edelete" "$HOME/.local/bin/edelete"
  link_file "$DOTFILES_WORKSPACE/bin/eupdate" "$HOME/.local/bin/eupdate"
  link_file "$DOTFILES_WORKSPACE/bin/eupgrade" "$HOME/.local/bin/eupgrade"
  link_file "$DOTFILES_WORKSPACE/bin/update" "$HOME/.local/bin/update"
  link_file "$DOTFILES_WORKSPACE/dots" "$HOME/.local/bin/dots"
  link_file "$DOTFILES_WORKSPACE/shared/bash_profile.sh" "$HOME/.bash_profile"
  link_file "$DOTFILES_WORKSPACE/shared/bashrc.sh" "$HOME/.bashrc"
  link_file --root "$DOTFILES_WORKSPACE/hosts/$_host.d/package-declare.conf" /etc/portage/package.declare/"$_host".conf
  link_file --root "$DOTFILES_WORKSPACE/hosts/$_host.d/package-keywords.conf" /etc/portage/package.accept_keywords/"$_host".conf
  link_file --root "$DOTFILES_WORKSPACE/hosts/$_host.d/package-license.conf" /etc/portage/package.license/"$_host".conf
  link_file --root "$DOTFILES_WORKSPACE/hosts/$_host.d/package-use.conf" /etc/portage/package.use/"$_host".conf
  link_file --root "$DOTFILES_WORKSPACE/shared/portage-overlays.conf" /etc/portage/repos.conf/overlays.conf
  link_file --root "$DOTFILES_WORKSPACE/shared/portage-package-mask.conf" /etc/portage/package.mask/mask.conf
  prune_stale_links

  "$HOME/.local/bin/update" --force

  install_gentoo_portage_config
}
