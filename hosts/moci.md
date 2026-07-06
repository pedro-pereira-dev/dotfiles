# `moci`

## Details

- Cloud: Oracle
- OS: Debian 13
- IPv4: `143.47.59.228`

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
rm -f /etc/ssh/sshd_config.d/test.conf
systemctl restart ssh

# sets up fstab
cat << 'EOF' > /etc/fstab
UUID=B2F4-D178                              /boot/efi   vfat    defaults,noatime,nodev,noexec,nosuid,umask=0077 0 2
UUID=b2a241d7-e806-4aef-87a6-e3fbf04849fa   none        swap    sw 0 0
UUID=dcf18ac7-47ae-4429-90b8-9161a1325922   /           ext4    defaults,errors=remount-ro 0 1
UUID=89a0806a-fb0b-409f-89e5-b7db643f2f5f   /data       ext4    defaults 0 0
EOF

# sets up grub
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=".*"/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/' /etc/default/grub
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
cat << 'EOF' > /usr/bin/update
#!/bin/sh
apt update
apt full-upgrade -y
apt autoremove -y
EOF
chmod +x /usr/bin/update
update

# sets up sftp
mkdir -p /data/.ssh /data/share/nedi-nas
useradd -d /data -s /sbin/nologin user
ssh-keygen -t ed25519 -f /data/.ssh/sftp_key -N "" -q
cat /data/.ssh/sftp_key.pub > /data/.ssh/authorized_keys
chmod -R 755 /data
chown root:root /data
chmod 600 /data/.ssh/authorized_keys
chmod 700 /data/.ssh
chown -R user:user /data/.ssh
chmod 755 /data/share
chown -R user:user /data/share
cat << 'EOF' > /etc/ssh/sshd_config.d/sftp.conf
Match User user
  AuthorizedKeysFile /data/.ssh/authorized_keys
  ChrootDirectory /data
  ForceCommand internal-sftp
EOF
systemctl restart ssh
#cat /data/.ssh/sftp_key

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
# neli-tunnel-moci
#[Peer]
#AllowedIPs = 10.10.10.8/32
#PublicKey = $(cat /etc/wireguard/server.pub)
$()
# neli-qbittorrent
#[Peer]
#AllowedIPs = 10.10.10.10/32
#PublicKey = $(cat /etc/wireguard/server.pub)
EOF
systemctl daemon-reload
systemctl enable --now wg-quick@wg0.service
#systemctl restart wg-quick@wg0.service

# sets up podman socket
apt install -y podman
systemctl enable --now podman-restart.service podman.service podman.socket

# enables unprivileged port start
cat << 'EOF' > /etc/sysctl.d/99-unprivileged-port-start.conf
net.ipv4.ip_unprivileged_port_start=0
EOF
sysctl --system >/dev/null 2>&1

# sets up rathole
mkdir -p /opt/podman/rathole
openssl rand -hex 64 > /opt/podman/rathole/token.key
cat << EOF > /opt/podman/rathole/server.toml
[server]
bind_addr = "0.0.0.0:2333"
default_token = "$(cat /opt/podman/rathole/token.key)"
$()
[server.services.neli-tunnel-moci-web-http]
bind_addr = "0.0.0.0:80"
[server.services.neli-tunnel-moci-web-https]
bind_addr = "0.0.0.0:443"
EOF
podman run -d --replace --restart always \
  --name moci-rathole \
  --network host \
  -v /opt/podman/rathole/server.toml:/server.toml \
  --health-cmd='["/app/rathole", "--version"]' \
  --health-on-failure restart \
  ghcr.io/rathole-org/rathole:dev /server.toml
#cat /opt/podman/rathole/token.key

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
#cat /opt/podman/hawser/token.key

# sets up firewall
apt install -y ufw
ufw default allow outgoing
ufw default deny incoming
# SSH
ufw allow from 0.0.0.0/0 to any port 22 proto tcp
# HTTP
ufw allow from 0.0.0.0/0 to any port 80 proto tcp
# HTTPS
ufw allow from 0.0.0.0/0 to any port 443 proto tcp
# Rathole
ufw allow in on wg0 from 10.0.0.0/8 to any port 2333 proto tcp
ufw allow in on wg0 from 172.16.0.0/12 to any port 2333 proto tcp
ufw allow in on wg0 from 192.168.0.0/16 to any port 2333 proto tcp
# Hawser
ufw allow in on wg0 from 10.0.0.0/8 to any port 2376 proto tcp
ufw allow in on wg0 from 172.16.0.0/12 to any port 2376 proto tcp
ufw allow in on wg0 from 192.168.0.0/16 to any port 2376 proto tcp
# Qbittorrent - torrenting
ufw allow from 0.0.0.0/0 to any port 6881 proto tcp
# Wireguard
ufw allow in on enp0s6 from 0.0.0.0/0 to any port 61820 proto udp
ufw enable

```
