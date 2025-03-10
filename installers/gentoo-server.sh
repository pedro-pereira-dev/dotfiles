#!/bin/bash

TARGET_HOSTNAME='gentoo-server'

bash <(wget -qO- https://raw.githubusercontent.com/pedro-pereira-dev/gentoo-installer/refs/heads/main/install.sh) \
  --hostname "${TARGET_HOSTNAME}" --username 'chuck'                                                              \
  --device 'vda' --device-separator ''                                                                            \
  --efi-size '+512M' --swap-size '+2G' --root-size ' '                                                            \
  --timezone 'Europe/Lisbon' --keymap 'pt-latin9'

chroot /mnt/gentoo /bin/bash <<EOF
env-update && source /etc/profile && export PS1="(chroot) \${PS1}"
bash <(wget -qO- https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/bootstrappers/${TARGET_HOSTNAME}.sh) --unsupervised ${TARGET_HOSTNAME}
EOF
