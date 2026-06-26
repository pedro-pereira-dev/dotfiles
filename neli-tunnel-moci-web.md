# `neli-tunnel-moci-web`

## Details

- Site: Personal
- OS: Debian 13
- IPv4: `192.168.0.10`

## Setup

```bash

# setup basic container
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/debian.sh)"
pct enter 1010

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

# installs dependencies
apt install -y podman ufw wireguard

# sets up wireguard
apt install -y wireguard
wg genkey | tee /etc/wireguard/client.key | wg pubkey > /etc/wireguard/client.pub
cat << EOF > /etc/wireguard/wg0.conf
# client
[Interface]
Address = 10.10.10.10/32
PrivateKey = $(cat /etc/wireguard/client.key)
$()
# moci
[Peer]
AllowedIPs = 10.10.10.1/32
Endpoint = wireguard.boarede.com:61820
PublicKey = $(cat /etc/wireguard/client.pub)
EOF
systemctl enable wg-quick@wg0.service
systemctl daemon-reload
systemctl start wg-quick@wg0.service

# restarts wireguard
systemctl daemon-reload
systemctl restart wg-quick@wg0.service
systemctl status wg-quick@wg0.service

# sets up podman socket
apt install -y podman
systemctl enable --now podman-restart.service podman.service podman.socket

# sets up rathole
mkdir -p /opt/podman/rathole
cat << EOF > /opt/podman/rathole/client.toml
[client]
remote_addr = "10.10.10.1:2333"
default_token = ""
$()
[client.services.neli-tunnel-moci-web-http]
local_addr = "0.0.0.0:80"
[client.services.neli-tunnel-moci-web-https]
local_addr = "0.0.0.0:443"
EOF
podman run -d --replace --restart always \
  --name neli-tunnel-moci-web-rathole \
  --network host \
  --health-cmd='["/app/rathole", "--version"]' \
  --health-on-failure restart \
  -v /opt/podman/rathole/client.toml:/client.toml \
  ghcr.io/rathole-org/rathole:dev /client.toml

# sets up hawser
mkdir -p /opt/podman/hawser
openssl rand -hex 64 > /opt/podman/hawser/token.key
podman run -d --replace --restart always \
  --name neli-tunnel-moci-web-hawser \
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
ufw allow in on eth0 from 10.0.0.0/8 to any port 22 proto tcp
ufw allow in on eth0 from 172.16.0.0/12 to any port 22 proto tcp
ufw allow in on eth0 from 192.168.0.0/16 to any port 22 proto tcp
# HTTP
ufw allow from 10.0.0.0/8 to any port 80 proto tcp
ufw allow from 172.16.0.0/12 to any port 80 proto tcp
ufw allow from 192.168.0.0/16 to any port 80 proto tcp
# HTTPS
ufw allow from 10.0.0.0/8 to any port 443 proto tcp
ufw allow from 172.16.0.0/12 to any port 443 proto tcp
ufw allow from 192.168.0.0/16 to any port 443 proto tcp
# Hawser
ufw allow in on eth0 from 10.0.0.0/8 to any port 2376 proto tcp
ufw allow in on eth0 from 172.16.0.0/12 to any port 2376 proto tcp
ufw allow in on eth0 from 192.168.0.0/16 to any port 2376 proto tcp
ufw enable

```
