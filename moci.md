# `moci`

## Details

- Cloud: Oracle
- OS: Debian 13
- IPv4: `79.72.63.98`

```
root@moci:~# lsblk -o NAME,FSTYPE,UUID,SIZE,FSAVAIL,MOUNTPOINTS
NAME   FSTYPE UUID                                   SIZE FSAVAIL MOUNTPOINTS
sda                                                  200G
├─sda1 vfat   CC5B-D676                               63M   57.1M /boot/efi
├─sda2 swap   78ae6219-c2ef-46cc-b1eb-964460b24f1e     1G         [SWAP]
├─sda3 ext4   01ee89a2-694c-47b8-8254-5ccfa1590870     8G    6.3G /
└─sda4 ext4   08f42bd2-369f-4e73-9050-4fab74d05a00 190.9G  177.3G /data
```

Ports opened:

```
```

## Initial system setup

```bash

# downloads netboot
apt install -y curl
mkdir -p /boot/efi/EFI/netboot
curl -Lfs https://boot.netboot.xyz/ipxe/netboot.xyz-arm64.efi -o /boot/efi/EFI/netboot/netboot.xyz-arm64.efi

# sets up ssh server
cat << 'EOF' > /root/.ssh/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd 11753516+pedro-pereira-dev@users.noreply.github.com
EOF
cat << 'EOF' > /etc/ssh/sshd_config.d/sshd.conf
PasswordAuthentication no
X11Forwarding no
EOF
systemctl restart ssh

# sets up fstab
cat << 'EOF' > /etc/fstab
UUID=CC5B-D676                              /boot/efi   vfat    defaults,noatime,nodev,noexec,nosuid,umask=0077 0 2
UUID=78ae6219-c2ef-46cc-b1eb-964460b24f1e   none        swap    sw 0 0
UUID=01ee89a2-694c-47b8-8254-5ccfa1590870   /           ext4    defaults,errors=remount-ro 0 1
UUID=08f42bd2-369f-4e73-9050-4fab74d05a00   /data       ext4    defaults 0 0
EOF

# disables ipv6 networking
cat << 'EOF' > /etc/sysctl.d/99-disable-ipv6.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
sysctl --system >/dev/null 2>&1

# sets up grub
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 ipv6.disable=1"/' /etc/default/grub
update-grub

# sets up apt
rm -f /etc/apt/sources.list /etc/apt/sources.list~ /etc/apt/sources.list.bak
cat << EOF > /etc/apt/sources.list.d/debian.sources
Types: deb
URIs: http://deb.debian.org/debian/
Suites: trixie
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
$()
Types: deb
URIs: http://deb.debian.org/debian/
Suites: trixie-updates
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
$()
Types: deb
URIs: http://security.debian.org/debian-security/
Suites: trixie-security
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF
cat << EOF > /usr/bin/update
#!/bin/sh
apt update
apt full-upgrade -y
apt autoremove -y
EOF
chmod +x /usr/bin/update
update

# installs all required dependencies
apt install -y podman ufw wireguard

# sets up wireguard
apt install -y wireguard
wg genkey | tee /etc/wireguard/server.key | wg pubkey > /etc/wireguard/server.pub
cat << EOF > /etc/wireguard/wg0.conf
# server
[Interface]
Address = 10.10.10.1/24
ListenPort = 61820
PrivateKey = $(cat /etc/wireguard/server.key)
$()
PreUp = sysctl -w net.ipv4.ip_forward=1
$()
PostUp = iptables -t nat -A POSTROUTING -o enp0s6 -j MASQUERADE
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT
$()
PostDown = iptables -t nat -D POSTROUTING -o enp0s6 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT
$()
# nedi-tunnel-moci
[Peer]
AllowedIPs = 10.10.10.10/32
PublicKey = $(cat /etc/wireguard/server.pub)
EOF
systemctl enable wg-quick@wg0.service
systemctl daemon-reload
systemctl start wg-quick@wg0.service

# sets up podman socket
apt install -y podman
systemctl enable --now podman-restart.service podman.service podman.socket

# sets up samba
mkdir -p /data/share /opt/podman/samba
chmod -R 777 /data/share
cat << EOF > /opt/podman/samba/config.yml
share:
  - name: public
    path: /share
    readonly: no
EOF
podman run -d --replace --restart always \
  --name moci-samba \
  --hostname moci-samba \
  --network host \
  -v /data/share:/share \
  -v /opt/podman/samba/config.yml:/data/config.yml \
  --health-cmd='["smbclient", "//127.0.0.1/public", "-N", "-c", "exit"]' \
  --health-on-failure restart \
  docker.io/crazymax/samba:latest

# sets up rathole
mkdir -p /opt/podman/rathole
openssl rand -hex 64 > /opt/podman/rathole/token.key
cat << EOF > /opt/podman/rathole/server.toml
[server]
bind_addr = "0.0.0.0:2333"
default_token = "$(cat /opt/podman/rathole/token.key)"
$()
[server.services.nedi-tunnel-moci]
bind_addr = "0.0.0.0:80"
[server.services.nedi-tunnel-moci]
bind_addr = "0.0.0.0:443"
EOF
podman run -d --replace --restart always \
  --name moci-rathole \
  --network host \
  -v /opt/podman/rathole/server.toml:/server.toml \
  --health-cmd='["/app/rathole", "--version"]' \
  --health-on-failure restart \
  ghcr.io/rathole-org/rathole:dev /server.toml

# sets up hawser
mkdir -p /opt/podman/hawser
openssl rand -hex 64 > /opt/podman/hawser/token.key
podman run -d --replace --restart always \
  --name moci-hawser \
  --network host \
  -e STACKS_DIR=/etc/hawser \
  -e TOKEN=$(cat /opt/podman/hawser/token.key) \
  -v /opt/podman/hawser:/etc/hawser \
  -v /run/podman/podman.sock:/var/run/docker.sock \
  --health-on-failure restart \
  ghcr.io/finsys/hawser:latest

# setup firewall
apt install -y ufw
ufw default allow outgoing
ufw default deny incoming
# Wireguard
ufw allow from 0.0.0.0/0 to any port 22 proto tcp
# SMB
ufw allow in on wg0 from 10.0.0.0/8 to any port 445 proto tcp
ufw allow in on wg0 from 172.16.0.0/12 to any port 445 proto tcp
ufw allow in on wg0 from 192.168.0.0/16 to any port 445 proto tcp
# Rathole
ufw allow in on wg0 from 10.0.0.0/8 to any port 2333 proto tcp
ufw allow in on wg0 from 172.16.0.0/12 to any port 2333 proto tcp
ufw allow in on wg0 from 192.168.0.0/16 to any port 2333 proto tcp
# Hawser
ufw allow in on wg0 from 10.0.0.0/8 to any port 2376 proto tcp
ufw allow in on wg0 from 172.16.0.0/12 to any port 2376 proto tcp
ufw allow in on wg0 from 192.168.0.0/16 to any port 2376 proto tcp
# Wireguard
ufw allow in on enp0s6 from 0.0.0.0/0 to any port 61820 proto udp
ufw enable

```
