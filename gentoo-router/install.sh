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
bash <(wget -qO- https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/bootstrap.sh) \
  --hostname gentoo-router --user chuck --password ${PASSWORD}
EOF
