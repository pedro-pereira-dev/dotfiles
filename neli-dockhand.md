# `neli-dockhand`

## Details

- Site: Personal
- OS: Debian 13
- IPv4: `192.168.0.70`

TBD

Ports opened:

```
root@neli-dockhand:~# ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp on eth0             ALLOW IN    10.0.0.0/8
22/tcp on eth0             ALLOW IN    172.16.0.0/12
22/tcp on eth0             ALLOW IN    192.168.0.0/16
2376/tcp on eth0           ALLOW IN    10.0.0.0/8
2376/tcp on eth0           ALLOW IN    172.16.0.0/12
2376/tcp on eth0           ALLOW IN    192.168.0.0/16
3000/tcp on eth0           ALLOW IN    10.0.0.0/8
3000/tcp on eth0           ALLOW IN    172.16.0.0/12
3000/tcp on eth0           ALLOW IN    192.168.0.0/16
```

#### To do:

TBD.

## Initial system setup

```bash
# setup basic container
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/debian.sh)"
# nesting, keyctl, fuse and tun
pct enter 1070

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
echo 'podman:1001:64535' > /etc/subgid
echo 'podman:1001:64535' > /etc/subuid
useradd -d /opt/podman -ms /bin/bash podman
loginctl enable-linger podman
systemctl --user -M podman@ enable --now podman.service podman.socket podman-restart.service
podman system connection add podman unix:///run/user/$(id -u podman)/podman/podman.sock
podman system connection default podman

# setup dockhand
runuser podman -c 'mkdir -p /opt/podman/dockhand'
podman --remote run -d --restart always \
  --name neli-dockhand-dockhand \
  --network host \
  -e DATA_DIR=/etc/dockhand \
  -v /opt/podman/dockhand:/etc/dockhand \
  -v /run/user/$(id -u podman)/podman/podman.sock:/var/run/docker.sock \
  docker.io/fnsys/dockhand:latest

# setup hawser
runuser podman -c 'mkdir -p /opt/podman/hawser'
podman --remote run -d --restart always \
  --name neli-dockhand-hawser \
  --network host \
  -e STACKS_DIR=/etc/hawser \
  -e TOKEN=$(openssl rand -hex 64) \
  -v /opt/podman/hawser:/etc/hawser \
  -v /run/user/$(id -u podman)/podman/podman.sock:/var/run/docker.sock \
  ghcr.io/finsys/hawser:latest
podman --remote inspect --format='{{range .Config.Env}}{{println .}}{{end}}' neli-dockhand-hawser | grep TOKEN | cut -d= -f2

# setup firewall
apt install -y ufw
ufw default allow outgoing
ufw default deny incoming
# ssh - 22
ufw allow in on eth0 from 10.0.0.0/8 to any port 22 proto tcp
ufw allow in on eth0 from 172.16.0.0/12 to any port 22 proto tcp
ufw allow in on eth0 from 192.168.0.0/16 to any port 22 proto tcp
# hawser - 2376
ufw allow in on eth0 from 10.0.0.0/8 to any port 2376 proto tcp
ufw allow in on eth0 from 172.16.0.0/12 to any port 2376 proto tcp
ufw allow in on eth0 from 192.168.0.0/16 to any port 2376 proto tcp
# dockhand - 3000
ufw allow in on eth0 from 10.0.0.0/8 to any port 3000 proto tcp
ufw allow in on eth0 from 172.16.0.0/12 to any port 3000 proto tcp
ufw allow in on eth0 from 192.168.0.0/16 to any port 3000 proto tcp
ufw enable

```
