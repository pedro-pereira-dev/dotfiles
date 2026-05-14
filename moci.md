# `moci`

## Details

- Cloud: Oracle
- OS: Debian 12 / Pxvirt 8
- IPv4: `79.72.63.98` / `10.0.0.30` / `10.0.10.1`

The server hosts a wireguard server, pihole for blocking domains and unbound for name resolution. Additionally, there is a rathole server for exposing private network services to the public internet from remote systems.

```
root@moci:~# lsblk -o NAME,FSTYPE,UUID,SIZE,FSAVAIL,MOUNTPOINTS
NAME              FSTYPE      UUID                                     SIZE FSAVAIL MOUNTPOINTS
sda                                                                    200G
├─sda1            vfat        CC5B-D676                                 63M   55.7M /boot/efi
└─sda2            LVM2_member qNSC1D-XN73-VPZn-Mf6A-QQf5-Prpp-4B3vkI 199.9G
  ├─vg-root       ext4        fb5fe93d-3636-446f-a455-6f5215e33b26      16G   10.6G /
  ├─vg-swap       swap        e75e2c54-b64c-4842-a340-d615767f2852       1G         [SWAP]
  ├─vg-data_tmeta                                                       92M
  │ └─vg-data                                                        182.8G
  └─vg-data_tdata                                                    182.8G
    └─vg-data                                                        182.8G
```

Ports opened:

```
root@moci:~# ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), deny (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere
8006/tcp                   ALLOW IN    Anywhere

Anywhere on enp0s6         ALLOW FWD   10.0.10.0/24 on vmbr0
10.0.10.15 80/tcp on vmbr0 ALLOW FWD   Anywhere on enp0s6
10.0.10.15 443/tcp on vmbr0 ALLOW FWD   Anywhere on enp0s6
10.0.10.10 61820/udp on vmbr0 ALLOW FWD   Anywhere on enp0s6
```

#### To do:

Restrict sensitive services to its own network interface - needed after the mesh network setup is done, (ie. ufw allow from 10.0.0.0/8 to any port 8080).
Host a storage sharing solution on /mnt/storage. Mining. Git hosting.
169.254.169.254

## Initial system setup

```bash

# setup ssh
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd 11753516+pedro-pereira-dev@users.noreply.github.com' > /root/.ssh/authorized_keys
echo 'PasswordAuthentication no' > /etc/ssh/sshd_config.d/sshd.conf
echo 'X11Forwarding no' >> /etc/ssh/sshd_config.d/sshd.conf
systemctl restart ssh

# setup netboot
apt install -y curl
mkdir -p /boot/efi/EFI/netboot
curl -Lfs https://boot.netboot.xyz/ipxe/netboot.xyz-arm64.efi -o /boot/efi/EFI/netboot/netboot.xyz-arm64.efi

# setup fstab
echo 'UUID=CC5B-D676          /boot/efi       vfat defaults,noatime,nodev,noexec,nosuid,umask=0077 0 2' > /etc/fstab
echo '/dev/mapper/vg-root     /               ext4 defaults,errors=remount-ro 0 1' >> /etc/fstab
echo '/dev/mapper/vg-swap     none            swap sw 0 0' >> /etc/fstab

# disable ipv6
echo 'net.ipv6.conf.all.disable_ipv6 = 1' > /etc/sysctl.d/99-disable-ipv6.conf
echo 'net.ipv6.conf.default.disable_ipv6 = 1' >> /etc/sysctl.d/99-disable-ipv6.conf
echo 'net.ipv6.conf.lo.disable_ipv6 = 1' >> /etc/sysctl.d/99-disable-ipv6.conf
sysctl --system

# setup grub
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 ipv6.disable=1"/' /etc/default/grub
update-grub

# setup apt
apt install -y curl
rm -f /etc/apt/sources.list /etc/apt/sources.list~ /etc/apt/sources.list.bak
curl -Lfs https://mirrors.lierfang.com/pxcloud/lierfang.gpg -o /etc/apt/trusted.gpg.d/lierfang.gpg
echo
echo 'deb http://deb.debian.org/debian/ bookworm main' > /etc/apt/sources.list.d/debian.list
echo 'deb http://deb.debian.org/debian/ bookworm-updates main' >> /etc/apt/sources.list.d/debian.list
echo 'deb http://security.debian.org/debian-security bookworm-security main' >> /etc/apt/sources.list.d/debian.list
echo
echo 'deb  https://mirrors.lierfang.com/pxcloud/pxvirt bookworm main' > /etc/apt/sources.list.d/pxvirt-sources.list
echo
apt update
apt full-upgrade -y

# setup hostname
echo
echo '127.0.0.1     localhost' > /etc/hosts
echo '10.0.0.30     moci' >> /etc/hosts
echo '' >> /etc/hosts
echo '# The following lines are desirable for IPv6 capable hosts' >> /etc/hosts
echo '::1       localhost ip6-localhost ip6-loopback' >> /etc/hosts
echo 'ff02::1   ip6-allnodes' >> /etc/hosts
echo 'ff02::2   ip6-allrouters' >> /etc/hosts
echo

# setup pxvirt dependencies
apt install -y proxmox-ve pve-manager qemu-server pve-cluster
# yes
systemctl reboot

# setup update scripts
echo
echo '#!/bin/sh' > /usr/bin/update
echo 'apt update' >> /usr/bin/update
echo 'apt full-upgrade -y' >> /usr/bin/update
echo 'apt autoremove -y' >> /usr/bin/update
echo
chmod +x /usr/bin/update

# setup network
apt install -y ifupdown2

# setup storage
lvcreate -l 100%FREE --thinpool data vg

# run pxvirt helper scripts
bash -c "$(curl -fsSL https://raw.githubusercontent.com/asylumexp/Proxmox/main/tools/pve/post-pve-install.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/asylumexp/Proxmox/main/tools/pve/kernel-clean.sh)"

# setup backup-host-to
echo
echo '#!/bin/bash' > /usr/bin/backup-host-to
echo '' >> /usr/bin/backup-host-to
echo '! /usr/sbin/pvesm status --storage "$1" >/dev/null 2>&1 &&' >> /usr/bin/backup-host-to
echo '  echo "Storage ($1) not found, skipping backup" &&' >> /usr/bin/backup-host-to
echo '  exit 1' >> /usr/bin/backup-host-to
echo '' >> /usr/bin/backup-host-to
echo 'PBS_DATASTORE=$(sed -n "/pbs: $1/,/^$/p" /etc/pve/storage.cfg | sed -n "s/\s.*datastore //p")' >> /usr/bin/backup-host-to
echo 'test -z "$PBS_DATASTORE" &&' >> /usr/bin/backup-host-to
echo '  echo "Storage ($1) configuration PBS_DATASTORE, skipping backup" &&' >> /usr/bin/backup-host-to
echo '  exit 1' >> /usr/bin/backup-host-to
echo '' >> /usr/bin/backup-host-to
echo 'PBS_NAMESPACE=$(sed -n "/pbs: $1/,/^$/p" /etc/pve/storage.cfg | sed -n "s/\s.*namespace //p")' >> /usr/bin/backup-host-to
echo 'test -z "$PBS_DATASTORE" &&' >> /usr/bin/backup-host-to
echo '  echo "Storage ($1) configuration PBS_NAMESPACE, skipping backup" &&' >> /usr/bin/backup-host-to
echo '  exit 1' >> /usr/bin/backup-host-to
echo '' >> /usr/bin/backup-host-to
echo 'PBS_SERVER=$(sed -n "/pbs: $1/,/^$/p" /etc/pve/storage.cfg | sed -n "s/\s.*server //p")' >> /usr/bin/backup-host-to
echo 'test -z "$PBS_DATASTORE" &&' >> /usr/bin/backup-host-to
echo '  echo "Storage ($1) configuration PBS_SERVER, skipping backup" &&' >> /usr/bin/backup-host-to
echo '  exit 1' >> /usr/bin/backup-host-to
echo '' >> /usr/bin/backup-host-to
echo 'PBS_USERNAME=$(sed -n "/pbs: $1/,/^$/p" /etc/pve/storage.cfg | sed -n "s/\s.*username //p")' >> /usr/bin/backup-host-to
echo 'test -z "$PBS_DATASTORE" &&' >> /usr/bin/backup-host-to
echo '  echo "Storage ($1) configuration PBS_USERNAME, skipping backup" &&' >> /usr/bin/backup-host-to
echo '  exit 1' >> /usr/bin/backup-host-to
echo '' >> /usr/bin/backup-host-to
echo 'PBS_FINGERPRINT=$(sed -n "/pbs: $1/,/^$/p" /etc/pve/storage.cfg | sed -n "s/\s.*fingerprint //p")' >> /usr/bin/backup-host-to
echo 'test -z "$PBS_DATASTORE" &&' >> /usr/bin/backup-host-to
echo '  echo "Storage ($1) configuration PBS_FINGERPRINT, skipping backup" &&' >> /usr/bin/backup-host-to
echo '  exit 1' >> /usr/bin/backup-host-to
echo '' >> /usr/bin/backup-host-to
echo 'PBS_PASSWORD=$(cat "/etc/pve/priv/storage/$1.pw")' >> /usr/bin/backup-host-to
echo 'test -z "$PBS_DATASTORE" &&' >> /usr/bin/backup-host-to
echo '  echo "Storage ($1) configuration PBS_PASSWORD, skipping backup" &&' >> /usr/bin/backup-host-to
echo '  exit 1' >> /usr/bin/backup-host-to
echo '' >> /usr/bin/backup-host-to
echo 'PBS_REPOSITORY="$PBS_USERNAME@$PBS_SERVER:$PBS_DATASTORE"' >> /usr/bin/backup-host-to
echo 'test -z "$PBS_DATASTORE" &&' >> /usr/bin/backup-host-to
echo '  echo "Storage ($1) configuration PBS_REPOSITORY, skipping backup" &&' >> /usr/bin/backup-host-to
echo '  exit 1' >> /usr/bin/backup-host-to
echo '' >> /usr/bin/backup-host-to
echo 'export PBS_FINGERPRINT PBS_PASSWORD PBS_REPOSITORY' >> /usr/bin/backup-host-to
echo '/usr/bin/proxmox-backup-client backup root.pxar:/ --ns "$PBS_NAMESPACE"' >> /usr/bin/backup-host-to
echo
chmod +x /usr/bin/backup-host-to
(crontab -l 2>/dev/null; echo "0 */3 * * * (sleep 60 && /usr/bin/backup-host-to moci-pbs-local)") | crontab -

# add dependencies
apt install -y btop neofetch ufw
reboot

# setup network
echo '# network interface settings; autogenerated' > /etc/network/interfaces
echo '# Please do NOT modify this file directly, unless you know what' >> /etc/network/interfaces
echo "# you're doing." >> /etc/network/interfaces
echo '#' >> /etc/network/interfaces
echo '# If you want to manage parts of the network configuration manually,' >> /etc/network/interfaces
echo "# please utilize the 'source' or 'source-directory' directives to do" >> /etc/network/interfaces
echo '# so.' >> /etc/network/interfaces
echo '# PVE will preserve these directives, but will NOT read its network' >> /etc/network/interfaces
echo '# configuration from sourced files, so do not attempt to move any of' >> /etc/network/interfaces
echo '# the PVE managed interfaces into external files!' >> /etc/network/interfaces
echo '' >> /etc/network/interfaces
echo 'source /etc/network/interfaces.d/*' >> /etc/network/interfaces
echo '' >> /etc/network/interfaces
echo 'auto lo' >> /etc/network/interfaces
echo 'iface lo inet loopback' >> /etc/network/interfaces
echo '' >> /etc/network/interfaces
echo 'auto enp0s6' >> /etc/network/interfaces
echo 'iface enp0s6 inet static' >> /etc/network/interfaces
echo '        address 10.0.0.30/24' >> /etc/network/interfaces
echo '        gateway 10.0.0.1' >> /etc/network/interfaces
echo '' >> /etc/network/interfaces
echo 'auto vmbr0' >> /etc/network/interfaces
echo 'iface vmbr0 inet manual' >> /etc/network/interfaces
echo '        address 10.0.10.1/24' >> /etc/network/interfaces
echo '        bridge-ports none' >> /etc/network/interfaces
echo '        bridge-stp off' >> /etc/network/interfaces
echo '        bridge-fd 0' >> /etc/network/interfaces
echo ''                    >> /etc/network/interfaces
echo '        # forward' >> /etc/network/interfaces
echo '        post-up   echo 1 > /proc/sys/net/ipv4/ip_forward' >> /etc/network/interfaces
echo ''                                                         >> /etc/network/interfaces
echo '        # masquerade' >> /etc/network/interfaces
echo "        post-up   iptables -t nat -A POSTROUTING -s '10.0.10.0/24' -o enp0s6 -j MASQUERADE" >> /etc/network/interfaces
echo "        post-down iptables -t nat -D POSTROUTING -s '10.0.10.0/24' -o enp0s6 -j MASQUERADE" >> /etc/network/interfaces
echo ''                                                                                           >> /etc/network/interfaces
echo '        # tcp 80 traffic to 10.0.10.15:80' >> /etc/network/interfaces
echo '        post-up   iptables -t nat -A PREROUTING -i enp0s6 -p tcp --dport 80 -j DNAT --to-destination 10.0.10.15:80' >> /etc/network/interfaces
echo '        post-down iptables -t nat -D PREROUTING -i enp0s6 -p tcp --dport 80 -j DNAT --to-destination 10.0.10.15:80' >> /etc/network/interfaces
echo ''                                                                                                                   >> /etc/network/interfaces
echo '        # tcp 443 traffic to 10.0.10.15:443' >> /etc/network/interfaces
echo '        post-up   iptables -t nat -A PREROUTING -i enp0s6 -p tcp --dport 443 -j DNAT --to-destination 10.0.10.15:443' >> /etc/network/interfaces
echo '        post-down iptables -t nat -D PREROUTING -i enp0s6 -p tcp --dport 443 -j DNAT --to-destination 10.0.10.15:443' >> /etc/network/interfaces
echo ''                                                                                                                     >> /etc/network/interfaces
echo '        # udp 61820 traffic to 10.0.10.10:61820' >> /etc/network/interfaces
echo '        post-up   iptables -t nat -A PREROUTING -i enp0s6 -p udp --dport 61820 -j DNAT --to-destination 10.0.10.10:61820' >> /etc/network/interfaces
echo '        post-down iptables -t nat -D PREROUTING -i enp0s6 -p udp --dport 61820 -j DNAT --to-destination 10.0.10.10:61820' >> /etc/network/interfaces

# iptables -t nat -A PREROUTING -i enp0s6 -p tcp --dport 8080 -j DNAT --to-destination 10.11.12.2:80 # port redirect
# iptables -A FORWARD -i enp0s6 -o vmbr0 -p tcp -d 10.11.12.2 --dport 80 -j ACCEPT # ufw setup for target port

# setup firewall
apt install -y ufw
ufw default allow outgoing
ufw default deny incoming
ufw allow 22/tcp                                                                # SSH
ufw allow 8006/tcp                                                              # Pxvirt
ufw route allow in on vmbr0 out on enp0s6 from 10.0.10.0/24                     # Forward vmbr0 to internet
ufw route allow in on enp0s6 out on vmbr0 to 10.0.10.15 port 80 proto tcp       # Forward HTTP to moci-rathole-server
ufw route allow in on enp0s6 out on vmbr0 to 10.0.10.15 port 443 proto tcp      # Forward HTTPs to moci-rathole-server
ufw route allow in on enp0s6 out on vmbr0 to 10.0.10.10 port 61820 proto udp    # Forward VPN to moci-wireguard-server
ufw enable

```
