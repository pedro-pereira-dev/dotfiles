# `nedi-jellyfin`

## Details

- Site: Personal
- OS: Debian 13
- IPv4: `192.168.0.14`

## Initial system setup

```bash

# creates debian lxc
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/debian.sh)"
# gpu passthrough
pct stop 1014

pct set 1014 -mp0 /mnt/pve/mnt-nas/nedi/media/,mp=/data
# enable protection
pct start 1014
pct enter 1014

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

# installs all required dependencies
apt install -y podman ufw

# sets up podman socket
apt install -y podman
systemctl enable --now podman-restart.service podman.service podman.socket

# sets up jellyfin
mkdir -p /opt/podman/jellyfin
podman run -d --replace --restart always \
  --name nedi-jellyfin \
  --network host \
  --device /dev/dri/card1:/dev/dri/card1 \
  --device /dev/dri/renderD128:/dev/dri/renderD128 \
  -e TZ=Europe/Lisbon \
  -v /data:/data \
  -v /opt/podman/jellyfin:/config \
  --health-cmd='["curl", "-f", "http://127.0.0.1:8096"]' \
  --health-on-failure restart \
  docker.io/jellyfin/jellyfin:latest

# sets up hawser
mkdir -p /opt/podman/hawser
openssl rand -hex 64 > /opt/podman/hawser/token.key
podman run -d --replace --restart always \
  --name nedi-jellyfin-hawser \
  --network host \
  -e STACKS_DIR=/etc/hawser \
  -e TOKEN=$(cat /opt/podman/hawser/token.key) \
  -v /opt/podman/hawser:/etc/hawser \
  -v /run/podman/podman.sock:/var/run/docker.sock \
  --health-on-failure restart \
  ghcr.io/finsys/hawser:latest

# sets up reboot on stale mount
(crontab -l 2>/dev/null; echo "* * * * * timeout 5 df -h || poweroff") | crontab -

# sets up firewall
apt install -y ufw
ufw default allow outgoing
ufw default deny incoming
# SSH
ufw allow in on eth0 from 10.0.0.0/8 to any port 22 proto tcp
ufw allow in on eth0 from 172.16.0.0/12 to any port 22 proto tcp
ufw allow in on eth0 from 192.168.0.0/16 to any port 22 proto tcp
# Hawser
ufw allow in on eth0 from 10.0.0.0/8 to any port 2376 proto tcp
ufw allow in on eth0 from 172.16.0.0/12 to any port 2376 proto tcp
ufw allow in on eth0 from 192.168.0.0/16 to any port 2376 proto tcp
# Jellyfin - Discovery
ufw allow in on eth0 from 10.0.0.0/8 to any port 7359 proto udp
ufw allow in on eth0 from 172.16.0.0/12 to any port 7359 proto udp
ufw allow in on eth0 from 192.168.0.0/16 to any port 7359 proto udp
# jellyfin - WebUI
ufw allow in on eth0 from 10.0.0.0/8 to any port 8096 proto tcp
ufw allow in on eth0 from 172.16.0.0/12 to any port 8096 proto tcp
ufw allow in on eth0 from 192.168.0.0/16 to any port 8096 proto tcp
ufw enable

```
