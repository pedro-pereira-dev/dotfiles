# `nedi-pihole`

## Details

- Site: Personal
- OS: Debian 13
- IPv4: `192.168.0.2`

Containerized Unbound / Pihole service for preferred name resolution server in home network.

Ports opened:

```
root@nedi-pihole:~# ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp on eth0             ALLOW IN    10.0.0.0/8
22/tcp on eth0             ALLOW IN    172.16.0.0/12
22/tcp on eth0             ALLOW IN    192.168.0.0/16
53 on eth0                 ALLOW IN    10.0.0.0/8
53 on eth0                 ALLOW IN    172.16.0.0/12
53 on eth0                 ALLOW IN    192.168.0.0/16
80/tcp on eth0             ALLOW IN    10.0.0.0/8
80/tcp on eth0             ALLOW IN    172.16.0.0/12
80/tcp on eth0             ALLOW IN    192.168.0.0/16
2376/tcp on eth0           ALLOW IN    10.0.0.0/8
2376/tcp on eth0           ALLOW IN    172.16.0.0/12
2376/tcp on eth0           ALLOW IN    192.168.0.0/16
```

#### To do:

TBD.

## Initial system setup

```bash
# setup basic container
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/debian.sh)"
# nesting, keyctl, fuse and tun
pct enter 1003

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

# enable unprivileged port start
echo 'net.ipv4.ip_unprivileged_port_start = 0' > /etc/sysctl.d/99-unprivileged-port-start.conf
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
echo 'podman:1001:64535' > /etc/subgid
echo 'podman:1001:64535' > /etc/subuid
useradd -d /opt/podman -ms /bin/bash podman
loginctl enable-linger podman
systemctl --user -M podman@ enable --now podman.service podman.socket podman-restart.service
podman system connection add podman unix:///run/user/$(id -u podman)/podman/podman.sock
podman system connection default podman

# setup unbound
runuser podman -c 'mkdir -p /opt/podman/unbound'
runuser podman -c 'touch /opt/podman/unbound/unbound.conf'
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
echo '  prefetch-key: yes' >> /opt/podman/unbound/unbound.conf
echo '  prefetch: yes' >> /opt/podman/unbound/unbound.conf
echo '  private-address: 10.0.0.0/8' >> /opt/podman/unbound/unbound.conf
echo '  private-address: 169.254.0.0/16' >> /opt/podman/unbound/unbound.conf
echo '  private-address: 172.16.0.0/12' >> /opt/podman/unbound/unbound.conf
echo '  private-address: 192.168.0.0/16' >> /opt/podman/unbound/unbound.conf
echo '  rrset-cache-size: 256m' >> /opt/podman/unbound/unbound.conf
echo '  verbosity: 0' >> /opt/podman/unbound/unbound.conf
echo
podman --remote run -d --restart always \
  --userns auto \
  --name nedi-pihole-unbound \
  -p 5353:53/tcp \
  -p 5353:53/udp \
  -v /opt/podman/unbound/unbound.conf:/etc/unbound/unbound.conf:U \
  docker.io/alpinelinux/unbound:latest

# setup pihole
runuser podman -c 'mkdir -p /opt/podman/pihole'
podman --remote run -d --restart always \
  --userns auto \
  --name nedi-pihole-pihole \
  --hostname nedi-pihole \
  -p 53:53/tcp \
  -p 53:53/udp \
  -p 80:80 \
  -e FTLCONF_dns_domainNeeded=true \
  -e FTLCONF_dns_domain_name='' \
  -e FTLCONF_dns_expandHosts=true \
  -e FTLCONF_dns_piholePTR=HOSTNAME \
  -e FTLCONF_dns_revServers='true,192.168.0.0/24,192.168.0.1' \
  -e FTLCONF_dns_upstreams=host.containers.internal#5353 \
  -e FTLCONF_ntp_ipv4_active=false \
  -e FTLCONF_ntp_ipv6_active=false \
  -e FTLCONF_ntp_sync_active=false \
  -e FTLCONF_webserver_api_password='' \
  -e FTLCONF_webserver_domain=pihole.nedi.boarede.com \
  -e FTLCONF_webserver_port=80o \
  -v /opt/podman/pihole:/etc/pihole:U \
  docker.io/pihole/pihole:latest
#podman --remote exec -it nedi-pihole-pihole pihole -g -f

# setup nebula-sync
podman --remote run -d --restart always \
  --userns auto \
  --name nedi-pihole-nebula-sync \
  -e CRON='* * * * *' \
  -e FULL_SYNC=true \
  -e PRIMARY='http://192.168.0.2|' \
  -e REPLICAS='http://host.containers.internal|' \
  -e RUN_GRAVITY=true \
  ghcr.io/lovelaze/nebula-sync:latest

# setup hawser
runuser podman -c 'mkdir -p /opt/podman/hawser'
podman --remote run -d --restart always \
  --userns auto \
  --name nedi-pihole-hawser \
  -p 2376:2376 \
  -e STACKS_DIR=/etc/hawser \
  -e TOKEN=$(openssl rand -hex 64) \
  -v /opt/podman/hawser:/etc/hawser:U \
  -v /run/user/$(id -u podman)/podman/podman.sock:/var/run/docker.sock:U \
  ghcr.io/finsys/hawser:latest
podman --remote inspect --format='{{range .Config.Env}}{{println .}}{{end}}' nedi-pihole-hawser | grep TOKEN | cut -d= -f2

# setup firewall
apt install -y ufw
ufw default allow outgoing
ufw default deny incoming
# ssh - 22
ufw allow in on eth0 from 10.0.0.0/8 to any port 22 proto tcp
ufw allow in on eth0 from 172.16.0.0/12 to any port 22 proto tcp
ufw allow in on eth0 from 192.168.0.0/16 to any port 22 proto tcp
# dns - 53
ufw allow in on eth0 from 10.0.0.0/8 to any port 53
ufw allow in on eth0 from 172.16.0.0/12 to any port 53
ufw allow in on eth0 from 192.168.0.0/16 to any port 53
# pihole webui - 80
ufw allow in on eth0 from 10.0.0.0/8 to any port 80 proto tcp
ufw allow in on eth0 from 172.16.0.0/12 to any port 80 proto tcp
ufw allow in on eth0 from 192.168.0.0/16 to any port 80 proto tcp
# hawser - 2376
ufw allow in on eth0 from 10.0.0.0/8 to any port 2376 proto tcp
ufw allow in on eth0 from 172.16.0.0/12 to any port 2376 proto tcp
ufw allow in on eth0 from 192.168.0.0/16 to any port 2376 proto tcp
ufw enable

```
