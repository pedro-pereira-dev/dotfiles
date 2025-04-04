#!/bin/bash
set -eo pipefail

while true; do
  echo 'Setting up system password:'
  read -r -s -p ' - Password: ' PASSWORD && echo ''
  read -r -s -p ' - Confirm password: ' PASSWORD_CONFIRMATION && echo ''
  [[ "${PASSWORD}" == "${PASSWORD_CONFIRMATION}" ]] && echo '' && break
  echo -e '\nPasswords do not match!'
done

bash <(wget -qO- https://raw.githubusercontent.com/pedro-pereira-dev/gentoo-installer/refs/heads/main/install.sh) \
  --hostname 'gentoo-router' --disk '/dev/sda' --password "${PASSWORD}"

chroot /mnt/gentoo /bin/bash <<EOF
env-update && source /etc/profile

bash <(wget -qO- https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/shared/dotfiles-installer/add-wheel-user.sh) \
  --hostname gentoo-router --user chuck --password ${PASSWORD}

emerge --ask=n --noreplace dev-vcs/git
su chuck -c 'mkdir --parents /home/chuck/workspace/personal'
su chuck -c 'git clone https://github.com/pedro-pereira-dev/dotfiles /home/chuck/workspace/personal/dotfiles'
/home/chuck/workspace/personal/dotfiles/shared/dotfiles-installer/bootstrap-dotfiles --hostname gentoo-router --user chuck

chown --changes root:root /etc/doas.conf
chmod --changes 0400 /etc/doas.conf
passwd --delete --lock root
EOF
