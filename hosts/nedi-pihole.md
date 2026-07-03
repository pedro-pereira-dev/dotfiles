# `nedi-pihole`

## Details

- Site: Personal
- OS: Debian 13
- IPv4: `192.168.0.2`

## Initial system setup

```bash

# creates debian lxc
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/debian.sh)"
pct enter 1002

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

# sets up unbound
mkdir -p /opt/podman/unbound
cat << 'EOF' > /opt/podman/unbound/unbound.conf
server:
  access-control: 10.0.0.0/8 allow
  access-control: 169.254.0.0/16 allow
  access-control: 172.16.0.0/12 allow
  access-control: 192.168.0.0/16 allow
  cache-max-ttl: 14400
  cache-min-ttl: 300
  do-ip6: no
  harden-referral-path: yes
  hide-identity: yes
  hide-version: yes
  interface: 0.0.0.0
  key-cache-size: 256m
  msg-cache-size: 256m
  neg-cache-size: 256m
  port: 5353
  prefetch-key: yes
  prefetch: yes
  private-address: 10.0.0.0/8
  private-address: 169.254.0.0/16
  private-address: 172.16.0.0/12
  private-address: 192.168.0.0/16
  rrset-cache-size: 256m
  so-sndbuf: 0
  verbosity: 0
EOF
podman run -d --replace --restart always \
  --name nedi-pihole-unbound \
  --network host \
  --health-cmd='["unbound-host", "gentoo.org"]' \
  --health-on-failure restart \
  -v /opt/podman/unbound/unbound.conf:/etc/unbound/unbound.conf \
  docker.io/alpinelinux/unbound:latest

# sets up pihole
mkdir -p /opt/podman/pihole
podman run -d --replace --restart always \
  --name nedi-pihole \
  --hostname nedi-pihole \
  --network host \
  -e FTLCONF_dns_domainNeeded=true \
  -e FTLCONF_dns_domain_name='' \
  -e FTLCONF_dns_expandHosts=true \
  -e FTLCONF_dns_piholePTR=HOSTNAME \
  -e FTLCONF_dns_revServers='true,192.168.0.0/24,192.168.0.1' \
  -e FTLCONF_dns_upstreams=127.0.0.1#5353 \
  -e FTLCONF_ntp_ipv4_active=false \
  -e FTLCONF_ntp_ipv6_active=false \
  -e FTLCONF_ntp_sync_active=false \
  -e FTLCONF_webserver_api_password='' \
  -e FTLCONF_webserver_domain=pihole.boarede.com \
  -e FTLCONF_webserver_port=80o \
  -e TZ=Europe/Lisbon \
  -v /opt/podman/pihole:/etc/pihole \
  --health-cmd='["curl", "-f", "http://127.0.0.1/admin"]' \
  --health-on-failure restart \
  docker.io/pihole/pihole:latest

# sets up hawser
mkdir -p /opt/podman/hawser
openssl rand -hex 64 > /opt/podman/hawser/token.key
podman run -d --replace --restart always \
  --name nedi-pihole-hawser \
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
# DNS
ufw allow from 10.0.0.0/8 to any port 53
ufw allow from 172.16.0.0/12 to any port 53
ufw allow from 192.168.0.0/16 to any port 53
# Pihole
ufw allow from 10.0.0.0/8 to any port 80 proto tcp
ufw allow from 172.16.0.0/12 to any port 80 proto tcp
ufw allow from 192.168.0.0/16 to any port 80 proto tcp
# Hawser
ufw allow from 10.0.0.0/8 to any port 2376 proto tcp
ufw allow from 172.16.0.0/12 to any port 2376 proto tcp
ufw allow from 192.168.0.0/16 to any port 2376 proto tcp
ufw enable

```
