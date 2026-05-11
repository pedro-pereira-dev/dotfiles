# `moci-rathole-server`

## Details

- Cloud: Oracle
- OS: Debian 13
- IPv4: `10.0.10.15`

Ports opened:

```
root@moci-rathole-server:~# ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), deny (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    10.0.0.0/8
22/tcp                     ALLOW IN    172.16.0.0/12
22/tcp                     ALLOW IN    192.168.0.0/16
80/tcp                     ALLOW IN    Anywhere
443/tcp                    ALLOW IN    Anywhere
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
pct enter 1015

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

# setup rathole
mkdir -p /opt/podman/rathole
echo
echo '[server]' > /opt/podman/rathole/server.toml
echo 'bind_addr = "0.0.0.0:3333"' >> /opt/podman/rathole/server.toml
echo "default_token = \"$(openssl rand -hex 64)\"" >> /opt/podman/rathole/server.toml
echo '' >> /opt/podman/rathole/server.toml
echo '[server.services.neli-proxy-http]' >> /opt/podman/rathole/server.toml
echo 'bind_addr = "0.0.0.0:80"' >> /opt/podman/rathole/server.toml
echo '[server.services.neli-proxy-https]' >> /opt/podman/rathole/server.toml
echo 'bind_addr = "0.0.0.0:443"' >> /opt/podman/rathole/server.toml
echo
podman run -d --restart always \
  --name moci-rathole-server \
  --network host \
  -v /opt/podman/rathole/server.toml:/server.toml \
  ghcr.io/rathole-org/rathole:dev /server.toml

# setup hawser
mkdir -p /opt/podman/hawser
podman run -d --restart always \
  --name moci-rathole-server-hawser \
  --network host \
  -e STACKS_DIR=/etc/hawser \
  -e TOKEN=$(openssl rand -hex 64) \
  -v /opt/podman/hawser:/etc/hawser \
  -v /run/podman/podman.sock:/var/run/docker.sock \
  ghcr.io/finsys/hawser:latest
podman inspect --format='{{range .Config.Env}}{{println .}}{{end}}' moci-rathole-server-hawser | grep TOKEN | cut -d= -f2

# setup firewall
apt install -y ufw
ufw default allow outgoing
ufw default deny incoming
# SSH
ufw allow from 10.0.0.0/8 to any port 22 proto tcp
ufw allow from 172.16.0.0/12 to any port 22 proto tcp
ufw allow from 192.168.0.0/16 to any port 22 proto tcp
# HTTP
ufw allow 80/tcp
# HTTPs
ufw allow 443/tcp
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
