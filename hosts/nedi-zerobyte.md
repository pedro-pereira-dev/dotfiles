# `nedi-zerobyte`

## Details

- Site: Personal
- OS: Debian 13
- IPv4: `192.168.0.7`

## Initial system setup

```bash

# creates debian lxc
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/debian.sh)"
# fuse - zerobyte
pct stop 1007

pct set 1007 -mp0 /mnt/pve/mnt-nas/,mp=/data
# enable protection
pct start 1007
pct enter 1007

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

# sets up zerobyte
mkdir -p /opt/podman/zerobyte
openssl rand -hex 64 > /opt/podman/zerobyte/secret.key
podman run -d --replace --restart always \
  --name nedi-zerobyte \
  --network host \
  --cap-add=SYS_ADMIN \
  --device /dev/fuse \
  -e APP_SECRET=$(cat /opt/podman/zerobyte/secret.key) \
  -e BASE_URL=http://192.168.0.7:4096 \
  -e TZ=Europe/Lisbon \
  -v /data:/data \
  -v /opt/podman/zerobyte:/var/lib/zerobyte \
  --health-cmd='["node", "-e", "fetch(\"http://192.168.0.7:4096/\").then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))"]' \
  --health-on-failure restart \
  ghcr.io/nicotsx/zerobyte:latest

# sets up hawser
mkdir -p /opt/podman/hawser
openssl rand -hex 64 > /opt/podman/hawser/token.key
podman run -d --replace --restart always \
  --name nedi-zerobyte-hawser \
  --network host \
  -e STACKS_DIR=/etc/hawser \
  -e TOKEN=$(cat /opt/podman/hawser/token.key) \
  -v /opt/podman/hawser:/etc/hawser \
  -v /run/podman/podman.sock:/var/run/docker.sock \
  --health-on-failure restart \
  ghcr.io/finsys/hawser:latest

# sets up firewall
apt install -y ufw
ufw default allow outgoing
ufw default deny incoming
# SSH
ufw allow from 10.0.0.0/8 to any port 22 proto tcp
ufw allow from 172.16.0.0/12 to any port 22 proto tcp
ufw allow from 192.168.0.0/16 to any port 22 proto tcp
# Hawser
ufw allow from 10.0.0.0/8 to any port 2376 proto tcp
ufw allow from 172.16.0.0/12 to any port 2376 proto tcp
ufw allow from 192.168.0.0/16 to any port 2376 proto tcp
# Zerobyte
ufw allow from 10.0.0.0/8 to any port 4096 proto tcp
ufw allow from 172.16.0.0/12 to any port 4096 proto tcp
ufw allow from 192.168.0.0/16 to any port 4096 proto tcp
ufw enable

```
