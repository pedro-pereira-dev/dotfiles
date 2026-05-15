# `neli-dockhand`

## Details

- Site: Personal
- OS: Debian 13
- IPv4: `192.168.0.40`

Ports opened:

```
root@neli-dockhand:~# ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), deny (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    10.0.0.0/8
22/tcp                     ALLOW IN    172.16.0.0/12
22/tcp                     ALLOW IN    192.168.0.0/16
2377/tcp                   ALLOW IN    10.0.0.0/8
2377/tcp                   ALLOW IN    172.16.0.0/12
2377/tcp                   ALLOW IN    192.168.0.0/16
3000/tcp                   ALLOW IN    10.0.0.0/8
3000/tcp                   ALLOW IN    172.16.0.0/12
3000/tcp                   ALLOW IN    192.168.0.0/16
```

## Initial system setup

```bash
# setup basic container
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/debian.sh)"
pct enter 1040

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

# setup dockhand
mkdir -p /opt/podman/dockhand
podman run -d --restart always \
  --name neli-dockhand \
  --network host \
  -e DATA_DIR=/etc/dockhand \
  -v /opt/podman/dockhand:/etc/dockhand \
  -v /run/podman/podman.sock:/var/run/docker.sock \
  --health-cmd='["curl", "-f", "http://127.0.0.1:3000"]' \
  --health-on-failure restart \
  docker.io/fnsys/dockhand:latest

# setup hawser
mkdir -p /opt/podman/hawser
openssl rand -hex 64 > /opt/podman/hawser/token.key
podman run -d --restart always \
  --name neli-dockhand-hawser \
  --network host \
  -e STACKS_DIR=/etc/hawser \
  -e TOKEN=$(cat /opt/podman/hawser/token.key) \
  -v /opt/podman/hawser:/etc/hawser \
  -v /run/podman/podman.sock:/var/run/docker.sock \
  --health-on-failure restart \
  ghcr.io/finsys/hawser:latest
cat /opt/podman/hawser/token.key

# setup firewall
apt install -y ufw
ufw default allow outgoing
ufw default deny incoming
# SSH
ufw allow from 10.0.0.0/8 to any port 22 proto tcp
ufw allow from 172.16.0.0/12 to any port 22 proto tcp
ufw allow from 192.168.0.0/16 to any port 22 proto tcp
# Hawser
ufw allow from 10.0.0.0/8 to any port 2377 proto tcp
ufw allow from 172.16.0.0/12 to any port 2377 proto tcp
ufw allow from 192.168.0.0/16 to any port 2377 proto tcp
# dockhand
ufw allow from 10.0.0.0/8 to any port 3000 proto tcp
ufw allow from 172.16.0.0/12 to any port 3000 proto tcp
ufw allow from 192.168.0.0/16 to any port 3000 proto tcp
ufw enable

```
