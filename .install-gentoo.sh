#!/bin/bash

# ---------------------------------------------------------------------
# the script installs gentoo using https://github.com/pedrojoaopereira/gentoo-installer
# and bootstraps the dotfiles from this repository with yadm
# it is recommended to run this from a debian-base system
# as 'apt' is a requirement to execute this script
#     usage: .install-gentoo.sh <hostname>
# ---------------------------------------------------------------------

# checks arguments and required dependencies
[[ -z $1 ]] && echo 'Usage: .install-gentoo.sh <hostname>' && exit 1
[[ -z $(command -v apt) ]] && echo 'Missing command "apt"' && exit 1

# gets templated username
HOSTNAME=$1
USERNAME=$(curl -s https://raw.githubusercontent.com/pedrojoaopereira/gentoo-installer/refs/heads/main/hosts/${HOSTNAME}.props | grep scripted_user | cut -d '=' -f2-)
[[ -z ${USERNAME} ]] && echo "gentoo-installer templates are missing hostname: ${HOSTNAME}" && exit 1

# installs gentoo from https://github.com/pedrojoaopereira/gentoo-installer
apt update && apt install curl wget git -y
bash <(curl -s https://raw.githubusercontent.com/pedrojoaopereira/gentoo-installer/refs/heads/main/web-install.sh) ${HOSTNAME}

# chroots back into the system to bootstrap with yadm
chroot /mnt/gentoo /bin/bash <<EOF
# updates environment settings
env-update && source /etc/profile && export PS1="(chroot) \${PS1}"

# installs yadm and bootstraps dotfiles
emerge --ask=n app-admin/yadm
su - ${USERNAME} -c 'yadm clone -f --no-bootstrap https://github.com/pedrojoaopereira/dotfiles'
/home/${USERNAME}/.config/yadm/bootstrap --unsupervised ${HOSTNAME}
EOF
