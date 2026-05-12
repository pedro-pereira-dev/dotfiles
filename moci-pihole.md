# `moci-pihole`

## Details

- Cloud: Oracle
- OS: Debian 13
- IPv4: `10.0.10.4`

Ports opened:

```
root@moci-pihole:~# ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), deny (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    10.0.0.0/8
22/tcp                     ALLOW IN    172.16.0.0/12
22/tcp                     ALLOW IN    192.168.0.0/16
53                         ALLOW IN    10.0.0.0/8
53                         ALLOW IN    172.16.0.0/12
53                         ALLOW IN    192.168.0.0/16
80/tcp                     ALLOW IN    10.0.0.0/8
80/tcp                     ALLOW IN    172.16.0.0/12
80/tcp                     ALLOW IN    192.168.0.0/16
2376/tcp                   ALLOW IN    10.0.0.0/8
2376/tcp                   ALLOW IN    172.16.0.0/12
2376/tcp                   ALLOW IN    192.168.0.0/16
3333/tcp                   ALLOW IN    10.0.0.0/8
3333/tcp                   ALLOW IN    172.16.0.0/12
3333/tcp                   ALLOW IN    192.168.0.0/16
```

## Initial system setup

```bash
# setup basic container
bash -c "$(curl -fsSL https://raw.githubusercontent.com/asylumexp/Proxmox/main/ct/debian.sh)"
# nesting, keyctl, fuse and tun
pct enter 1004

# fix arm networking while installing
systemctl disable --now systemd-networkd systemd-resolved
systemctl restart networking

# ---

# setup ssh
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd 11753516+pedro-pereira-dev@users.noreply.github.com' > /root/.ssh/authorized_keys
echo 'PasswordAuthentication no' > /etc/ssh/sshd_config.d/sshd.conf
echo 'X11Forwarding no' >> /etc/ssh/sshd_config.d/sshd.conf
systemctl restart ssh

# disable ipv6
echo 'net.ipv6.conf.all.disable_ipv6 = 1' > /etc/sysctl.d/99-disable-ipv6.conf
echo 'net.ipv6.conf.default.disable_ipv6 = 1' >> /etc/sysctl.d/99-disable-ipv6.conf
echo 'net.ipv6.conf.lo.disable_ipv6 = 1' >> /etc/sysctl.d/99-disable-ipv6.conf
sysctl --system

# setup apt
rm -f /etc/apt/sources.list /etc/apt/sources.list~ /etc/apt/sources.list.bak
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

# setup update scripts
echo
echo '#!/bin/sh' > /usr/bin/update
echo 'apt update' >> /usr/bin/update
echo 'apt full-upgrade -y' >> /usr/bin/update
echo 'apt autoremove -y' >> /usr/bin/update
echo
chmod +x /usr/bin/update

# install dependencies
apt install -y crun podman ufw

# setup podman
apt install -y crun podman
systemctl enable --now podman-restart.service podman.service podman.socket

# setup unbound
mkdir -p /opt/podman/unbound
echo
echo 'server:' > /opt/podman/unbound/unbound.conf
echo '  access-control: 10.0.0.0/8 allow' >> /opt/podman/unbound/unbound.conf
echo '  access-control: 169.254.0.0/16 allow' >> /opt/podman/unbound/unbound.conf
echo '  access-control: 172.16.0.0/12 allow' >> /opt/podman/unbound/unbound.conf
echo '  access-control: 192.168.0.0/16 allow' >> /opt/podman/unbound/unbound.conf
echo '  cache-max-ttl: 14400' >> /opt/podman/unbound/unbound.conf
echo '  cache-min-ttl: 300' >> /opt/podman/unbound/unbound.conf
echo '  do-ip6: no' >> /opt/podman/unbound/unbound.conf
echo '  harden-referral-path: yes' >> /opt/podman/unbound/unbound.conf
echo '  hide-identity: yes' >> /opt/podman/unbound/unbound.conf
echo '  hide-version: yes' >> /opt/podman/unbound/unbound.conf
echo '  interface: 0.0.0.0' >> /opt/podman/unbound/unbound.conf
echo '  key-cache-size: 256m' >> /opt/podman/unbound/unbound.conf
echo '  msg-cache-size: 256m' >> /opt/podman/unbound/unbound.conf
echo '  neg-cache-size: 256m' >> /opt/podman/unbound/unbound.conf
echo '  port: 5353' >> /opt/podman/unbound/unbound.conf
echo '  prefetch-key: yes' >> /opt/podman/unbound/unbound.conf
echo '  prefetch: yes' >> /opt/podman/unbound/unbound.conf
echo '  private-address: 10.0.0.0/8' >> /opt/podman/unbound/unbound.conf
echo '  private-address: 169.254.0.0/16' >> /opt/podman/unbound/unbound.conf
echo '  private-address: 172.16.0.0/12' >> /opt/podman/unbound/unbound.conf
echo '  private-address: 192.168.0.0/16' >> /opt/podman/unbound/unbound.conf
echo '  rrset-cache-size: 256m' >> /opt/podman/unbound/unbound.conf
echo '  so-sndbuf: 0' >> /opt/podman/unbound/unbound.conf
echo '  verbosity: 0' >> /opt/podman/unbound/unbound.conf
echo
podman run -d --restart always \
  --name moci-pihole-unbound \
  --network host \
  -v /opt/podman/unbound/unbound.conf:/etc/unbound/unbound.conf \
  docker.io/alpinelinux/unbound:latest

# setup pihole
mkdir -p /opt/podman/pihole
podman run -d --restart always \
  --name moci-pihole \
  --hostname moci-pihole \
  --network host \
  -e FTLCONF_dns_domainNeeded=true \
  -e FTLCONF_dns_domain_name='' \
  -e FTLCONF_dns_expandHosts=true \
  -e FTLCONF_dns_piholePTR=HOSTNAME \
  -e FTLCONF_dns_upstreams=127.0.0.1#5353 \
  -e FTLCONF_ntp_ipv4_active=false \
  -e FTLCONF_ntp_ipv6_active=false \
  -e FTLCONF_ntp_sync_active=false \
  -e FTLCONF_webserver_api_password='' \
  -e FTLCONF_webserver_domain=pihole.moci.boarede.com \
  -e FTLCONF_webserver_port=80o \
  -v /opt/podman/pihole:/etc/pihole \
  docker.io/pihole/pihole:latest

# setup rathole
mkdir -p /opt/podman/rathole
echo
echo '[server]' > /opt/podman/rathole/server.toml
echo 'bind_addr = "0.0.0.0:3333"' >> /opt/podman/rathole/server.toml
echo "default_token = \"$(openssl rand -hex 64)\"" >> /opt/podman/rathole/server.toml
echo '' >> /opt/podman/rathole/server.toml
echo '[server.services.neli-pihole]' >> /opt/podman/rathole/server.toml
echo 'bind_addr = "127.0.0.1:8181"' >> /opt/podman/rathole/server.toml
echo
podman run -d --restart always \
  --name moci-pihole-rathole \
  --network host \
  -v /opt/podman/rathole/server.toml:/server.toml \
  ghcr.io/rathole-org/rathole:dev /server.toml

# setup nebula-sync
podman run -d --restart always \
  --name moci-pihole-nebula-sync \
  --network host \
  -e CRON='0 8 * * *' \
  -e FULL_SYNC=true \
  -e PRIMARY='http://127.0.0.1:8181|' \
  -e REPLICAS='http://127.0.0.1|' \
  -e RUN_GRAVITY=true \
  ghcr.io/lovelaze/nebula-sync:latest

# setup hawser
mkdir -p /opt/podman/hawser
podman run -d --restart always \
  --name moci-pihole-hawser \
  --network host \
  -e STACKS_DIR=/etc/hawser \
  -e TOKEN=$(openssl rand -hex 64) \
  -v /opt/podman/hawser:/etc/hawser \
  -v /run/podman/podman.sock:/var/run/docker.sock \
  ghcr.io/finsys/hawser:latest
podman inspect --format='{{range .Config.Env}}{{println .}}{{end}}' moci-pihole-hawser | grep TOKEN | cut -d= -f2

# setup firewall
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
# Rathole        
ufw allow from 10.0.0.0/8 to any port 3333 proto tcp
ufw allow from 172.16.0.0/12 to any port 3333 proto tcp
ufw allow from 192.168.0.0/16 to any port 3333 proto tcp
ufw enable

```
