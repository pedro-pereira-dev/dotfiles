# `moci-share`

## Details

- Cloud: Oracle
- OS: Debian 13
- IPv4: `10.0.10.46`

Ports opened:

```
root@moci-share:/data# ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), deny (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    10.0.0.0/8
22/tcp                     ALLOW IN    172.16.0.0/12
22/tcp                     ALLOW IN    192.168.0.0/16
```

## Initial system setup

```bash
# setup basic container
bash -c "$(curl -fsSL https://raw.githubusercontent.com/asylumexp/Proxmox/main/ct/debian.sh)"
# add 128gb disk to /data
pct enter 1046

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
apt install -y ufw

# setup user
mkdir -p /opt/share
useradd -ms /usr/bin/false share
openssl rand -hex 64 > /opt/share/share.key
passwd --stdin share < /opt/share/share.key

# setup share
mkdir -p /data/share
chmod 777 /data/share
chown -R nobody:nogroup /data/share

# setup sftp
echo
echo 'Match User share' > /etc/ssh/sshd_config.d/sftp.conf
echo '  AllowTcpForwarding no' >> /etc/ssh/sshd_config.d/sftp.conf
echo '  ChrootDirectory /data' >> /etc/ssh/sshd_config.d/sftp.conf
echo '  ForceCommand internal-sftp' >> /etc/ssh/sshd_config.d/sftp.conf
echo '  PasswordAuthentication yes' >> /etc/ssh/sshd_config.d/sftp.conf
echo
systemctl restart ssh

# setup firewall
apt install -y ufw
ufw default allow outgoing
ufw default deny incoming
# SSH
ufw allow from 10.0.0.0/8 to any port 22 proto tcp
ufw allow from 172.16.0.0/12 to any port 22 proto tcp
ufw allow from 192.168.0.0/16 to any port 22 proto tcp
ufw enable

```
