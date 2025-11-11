#!/bin/sh
# shellcheck source=/dev/null
set -eou pipefail

_HOSTNAME=gs-proxy
_USER=chuck

configure() {
  run_as_root ln -fsv "$_HOME/workspace/personal/dotfiles/dots.sh" /usr/bin/dots

  ! command -v doas /dev/null && run_as_root emerge --ask=n -n app-admin/doas
  command -v doas /dev/null &&
    run_as_root cp -f "$_HOME/workspace/personal/dotfiles/files/system-doas.conf" /etc/doas.conf &&
    run_as_root chown root:root /etc/doas.conf && run_as_root chmod 0400 /etc/doas.conf && run_as_root passwd -dl root

  run_as_root ln -fsv "$_HOME/workspace/personal/dotfiles/files/portage-eauto.sh" /usr/bin/eauto
  run_as_root ln -fsv "$_HOME/workspace/personal/dotfiles/files/portage-edeclare.sh" /usr/bin/edeclare
  run_as_root ln -fsv "$_HOME/workspace/personal/dotfiles/files/portage-edelete.sh" /usr/bin/edelete
  run_as_root ln -fsv "$_HOME/workspace/personal/dotfiles/files/portage-eupdate.sh" /usr/bin/eupdate
  run_as_root ln -fsv "$_HOME/workspace/personal/dotfiles/files/portage-eupgrade.sh" /usr/bin/eupgrade
  run_as_root ln -fsv "$_HOME/workspace/personal/dotfiles/files/portage-mask.conf" /etc/portage/package.mask
  run_as_root ln -fsv "$_HOME/workspace/personal/dotfiles/files/portage-overlays.conf" /etc/portage/repos.conf/overlays.conf
  run_as_root ln -fsv "$_HOME/workspace/personal/dotfiles/files/system-grub.conf" /etc/default/grub

  get_option --full "$@" &&
    run_as_root /usr/bin/eauto --unsupervised &&
    run_as_root /usr/bin/installkernel &&
    run_as_root eselect news read --quiet all

  run_as_root rc-update add sshd default >/dev/null

  run_as_root rm -fr /efi/EFI/NETBOOT
  run_as_root mkdir -p /efi/EFI/NETBOOT
  run_as_root curl -Lfs https://boot.netboot.xyz/ipxe/netboot.xyz-arm64.efi -o /efi/EFI/NETBOOT/netboot.xyz-arm64.efi
}
