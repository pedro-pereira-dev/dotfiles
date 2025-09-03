#!/bin/bash

echo -e "\nGathering installation setup..."
while true; do
  read -r -s -p ' - System password: ' SYSTEM_PASSWORD && echo
  [[ -z ${SYSTEM_PASSWORD} ]] && continue
  read -r -s -p ' - Confirm system password: ' PASSWORD_CONFIRMATION && echo
  [[ "${SYSTEM_PASSWORD}" == "${PASSWORD_CONFIRMATION}" ]] && break
done

wipefs --all /dev/sda
sed --expression='s/\s*\([\+0-9a-zA-Z]*\).*/\1/' <<EOF | fdisk /dev/sda
    o  # create empty MBR partition table
    n  # create boot partition
    # choose default partition type
    # choose default partition number
    # choose default sector number
    +256M
    a  # mark partition as bootable
    n  # create root partition
    # choose default partition type
    # choose default partition number
    # choose default sector number
    +16G
    n  # create root partition
    # choose default partition type
    # choose default partition number
    # choose default sector number
    # fill disk with new partition
    p  # print partition table
    w  # write changes to disk
EOF

bash <(wget --output-document=- --quiet https://raw.githubusercontent.com/pedro-pereira-dev/gentoo-installer/refs/heads/main/install.sh) \
  --boot '/dev/sda1' \
  --hostname 'gentoo-server-hetzner-proxy' \
  --keymap 'pt-latin9' \
  --password "${SYSTEM_PASSWORD}" \
  --root '/dev/sda2' \
  --timezone 'Europe/Lisbon'

chroot /mnt /bin/bash <<EOF
env-update && source /etc/profile

useradd --create-home --shell /bin/bash chuck
usermod --append --groups wheel chuck
chown --changes --recursive chuck:chuck /home/chuck
echo "chuck:${SYSTEM_PASSWORD}" | chpasswd

emerge --ask=n --noreplace app-portage/eix dev-vcs/git
su chuck -c 'mkdir --parents /home/chuck/workspace/personal'
su chuck -c 'git clone https://github.com/pedro-pereira-dev/dotfiles /home/chuck/workspace/personal/dotfiles'
/home/chuck/workspace/personal/dotfiles/shared/scripts/utils.bootstrap-dotfiles --hostname gentoo-server-hetzner-proxy --user chuck
EOF
