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
  --hostname 'gentoo-laptop' --disk '/dev/nvme0n1' --root-size '+64G' --password "${PASSWORD}"

chroot /mnt/gentoo /bin/bash <<EOF
env-update && source /etc/profile

bash <(wget -qO- https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/add-wheel-user.sh) \
  --hostname gentoo-laptop --user chuck --password ${PASSWORD}

emerge --ask=n --noreplace dev-vcs/git
su chuck -c 'mkdir --parents /home/chuck/workspace/personal'
su chuck -c 'git clone https://github.com/pedro-pereira-dev/dotfiles /home/chuck/workspace/personal/dotfiles'
/home/chuck/workspace/personal/dotfiles/shared/scripts/utils.bootstrap-dotfiles --hostname gentoo-laptop --user chuck
EOF
