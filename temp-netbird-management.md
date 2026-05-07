# `neli-netbird-management`

## Details

- Site: Personal
- OS: Debian 13
- IPv4: `192.168.0.50`

Containerized Wireguard and Rathole client to proxy `moci` server and dockerized Netbird management plane.

Ports opened:
- local network
  TBD

#### To do:

TBD.

## Initial system setup

```bash
# setup basic container
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/debian.sh)"
pct enter 1050

# setup ssh
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd 11753516+pedro-pereira-dev@users.noreply.github.com' > /root/.ssh/authorized_keys
echo 'PasswordAuthentication no' > /etc/ssh/sshd_config.d/sshd.conf
echo 'X11Forwarding no' >> /etc/ssh/sshd_config.d/sshd.conf
systemctl restart ssh

# setup apt
echo
echo 'Types: deb' > /etc/apt/sources.list.d/debian.sources
echo 'URIs: http://deb.debian.org/debian/' >> /etc/apt/sources.list.d/debian.sources
echo 'Suites: trixie' >> /etc/apt/sources.list.d/debian.sources
echo 'Components: main' >> /etc/apt/sources.list.d/debian.sources
echo 'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' >> /etc/apt/sources.list.d/debian.sources
echo '' >> /etc/apt/sources.list.d/debian.sources
echo 'Types: deb' >> /etc/apt/sources.list.d/debian.sources
echo 'URIs: http://deb.debian.org/debian/' >> /etc/apt/sources.list.d/debian.sources
echo 'Suites: trixie-updates' >> /etc/apt/sources.list.d/debian.sources
echo 'Components: main' >> /etc/apt/sources.list.d/debian.sources
echo 'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' >> /etc/apt/sources.list.d/debian.sources
echo '' >> /etc/apt/sources.list.d/debian.sources
echo 'Types: deb' >> /etc/apt/sources.list.d/debian.sources
echo 'URIs: http://security.debian.org/debian-security/' >> /etc/apt/sources.list.d/debian.sources
echo 'Suites: trixie-security' >> /etc/apt/sources.list.d/debian.sources
echo 'Components: main' >> /etc/apt/sources.list.d/debian.sources
echo 'Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg' >> /etc/apt/sources.list.d/debian.sources
echo
apt update
apt full-upgrade -y

# setup wireguard
apt install -y ufw wireguard
cd /etc/wireguard
umask 077
wg genkey | tee wgclient.key | wg pubkey > wgclient.pub
echo
echo '[Interface]' > /etc/wireguard/wg0.conf
echo 'Address = 10.100.100.70/32' >> /etc/wireguard/wg0.conf
echo "PrivateKey = $(cat /etc/wireguard/wgclient.key)" >> /etc/wireguard/wg0.conf
echo '' >> /etc/wireguard/wg0.conf
echo '[Peer]' >> /etc/wireguard/wg0.conf
echo 'AllowedIPs = 10.100.100.1/32' >> /etc/wireguard/wg0.conf
echo 'Endpoint = 79.72.63.98:61820' >> /etc/wireguard/wg0.conf
echo 'PublicKey = ' >> /etc/wireguard/wg0.conf
echo
systemctl enable wg-quick@wg0.service
systemctl daemon-reload
systemctl start wg-quick@wg0

# setup rathole
echo
echo '#!/bin/sh' > /usr/bin/update-rathole
echo 'curl -Lfs "$(' >> /usr/bin/update-rathole
echo '  curl -s https://api.github.com/repos/rathole-org/rathole/releases/latest |' >> /usr/bin/update-rathole
echo "    jq -r --arg ARCH \"$(uname -m)\" --arg OS \"$(uname -s | tr '[:upper:]' '[:lower:]')\" \\" >> /usr/bin/update-rathole
echo "      '.assets[] | select(.name | contains(\$ARCH) and contains(\$OS)) | .browser_download_url'" >> /usr/bin/update-rathole
echo ')" -o /tmp/rathole.zip' >> /usr/bin/update-rathole
echo 'unzip -o /tmp/rathole.zip -d /usr/bin/ >/dev/null' >> /usr/bin/update-rathole
echo 'chmod +x /usr/bin/rathole' >> /usr/bin/update-rathole
echo 'rm -fr /tmp/rathole.zip' >> /usr/bin/update-rathole
echo
chmod +x /usr/bin/update-rathole
/usr/bin/update-rathole
mkdir -p /etc/rathole
echo
echo '[client]' > /etc/rathole/rathole.toml
echo 'remote_addr = "10.100.100.1:2333"' >> /etc/rathole/rathole.toml
echo "default_token = \"\"" >> /etc/rathole/rathole.toml
echo '[client.services.http]' >> /etc/rathole/rathole.toml
echo 'local_addr = "127.0.0.1:80"' >> /etc/rathole/rathole.toml
echo '[client.services.https]' >> /etc/rathole/rathole.toml
echo 'local_addr = "127.0.0.1:443"' >> /etc/rathole/rathole.toml
echo '[client.services.turn]' >> /etc/rathole/rathole.toml
echo 'local_addr = "127.0.0.1:3478"' >> /etc/rathole/rathole.toml
echo '[client.services.wireguard]' >> /etc/rathole/rathole.toml
echo 'local_addr = "127.0.0.1:51820"' >> /etc/rathole/rathole.toml
echo
echo '[Unit]' > /etc/systemd/system/rathole.service
echo 'Description=Rathole Client Service' >> /etc/systemd/system/rathole.service
echo 'After=network.target' >> /etc/systemd/system/rathole.service
echo '' >> /etc/systemd/system/rathole.service
echo '[Service]' >> /etc/systemd/system/rathole.service
echo 'Type=simple' >> /etc/systemd/system/rathole.service
echo 'ExecStart=/usr/bin/rathole /etc/rathole/rathole.toml' >> /etc/systemd/system/rathole.service
echo 'Restart=on-failure' >> /etc/systemd/system/rathole.service
echo 'RestartSec=5s' >> /etc/systemd/system/rathole.service
echo '' >> /etc/systemd/system/rathole.service
echo '[Install]' >> /etc/systemd/system/rathole.service
echo 'WantedBy=multi-user.target' >> /etc/systemd/system/rathole.service
echo
systemctl enable rathole.service
systemctl daemon-reload
systemctl start rathole.service

# install docker
bash -c "$(curl -fsSL https://get.docker.com)"

# install netbird
mkdir netbird
cd netbird
bash -c "$(curl -fsSL https://github.com/netbirdio/netbird/releases/latest/download/getting-started.sh)"

# setup update scripts
echo
echo '#!/bin/sh' > /usr/bin/update
echo 'bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/debian.sh)"' >> /usr/bin/update
echo 'apt autoremove -y' >> /usr/bin/update
echo 'update-rathole' >> /usr/bin/update
echo
chmod +x /usr/bin/update

# setup firewall
apt install -y ufw
ufw default allow outgoing
ufw default deny incoming
# ssh - 22
ufw allow in on eth0 from 10.0.0.0/8 to any port 22 proto tcp
ufw allow in on eth0 from 172.16.0.0/12 to any port 22 proto tcp
ufw allow in on eth0 from 192.168.0.0/16 to any port 22 proto tcp
ufw enable
```
