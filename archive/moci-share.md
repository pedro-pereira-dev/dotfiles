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
apt install -y crun podman ufw

# setup podman
apt install -y crun podman
systemctl enable --now podman-restart.service podman.service podman.socket

# setup share
mkdir -p /data/share
chmod 777 /data/share
chown -R nobody:nogroup /data/share

# setup users
mkdir -p /opt/podman/samba
echo
echo '#username:uid:groupname:gid:password:homedir' > /opt/podman/samba/users.conf
echo "admin:1000:admin:1000:$(openssl rand -hex 64)" >> /opt/podman/samba/users.conf
echo "backup:1001:backup:1001:$(openssl rand -hex 64)" >> /opt/podman/samba/users.conf
echo

# setup samba
mkdir -p /opt/podman/samba
echo
echo "admin:1000:admin:1000:$(openssl rand -hex 64)" > /opt/podman/samba/users.conf
echo "test:1001:admin:1000:$(openssl rand -hex 64)" >> /opt/podman/samba/users.conf
echo
echo '[global]' > /opt/podman/samba/smb.conf
echo '   server string = samba' >> /opt/podman/samba/smb.conf
echo '   idmap config * : range = 3000-7999' >> /opt/podman/samba/smb.conf
echo '   security = user' >> /opt/podman/samba/smb.conf
echo '   server min protocol = SMB2' >> /opt/podman/samba/smb.conf
echo '' >> /opt/podman/samba/smb.conf
echo '   # disable printing services' >> /opt/podman/samba/smb.conf
echo '   load printers = no' >> /opt/podman/samba/smb.conf
echo '   printing = bsd' >> /opt/podman/samba/smb.conf
echo '   printcap name = /dev/null' >> /opt/podman/samba/smb.conf
echo '   disable spoolss = yes' >> /opt/podman/samba/smb.conf
echo '' >> /opt/podman/samba/smb.conf
echo '   host msdfs = no' >> /opt/podman/samba/smb.conf
echo '   wide links = yes' >> /opt/podman/samba/smb.conf
echo '   follow symlinks = yes' >> /opt/podman/samba/smb.conf
echo '   unix extensions = no' >> /opt/podman/samba/smb.conf
echo '   acl allow execute always = yes' >> /opt/podman/samba/smb.conf
echo '' >> /opt/podman/samba/smb.conf
echo '   # allow SMB clients to read/write extended attributes (xattrs) on files' >> /opt/podman/samba/smb.conf
echo '   # enabled to support vfs_streams_xattr' >> /opt/podman/samba/smb.conf
echo '   ea support = yes' >> /opt/podman/samba/smb.conf
echo '' >> /opt/podman/samba/smb.conf
echo '   # MacOS Compatibility options' >> /opt/podman/samba/smb.conf
echo '   vfs objects = catia fruit streams_xattr' >> /opt/podman/samba/smb.conf
echo '   fruit:resource = file' >> /opt/podman/samba/smb.conf
echo '   fruit:metadata = stream' >> /opt/podman/samba/smb.conf
echo '   fruit:locking = netatalk' >> /opt/podman/samba/smb.conf
echo '   fruit:encoding = native' >> /opt/podman/samba/smb.conf
echo '' >> /opt/podman/samba/smb.conf
echo '   # Special configuration for Apples Time Machine' >> /opt/podman/samba/smb.conf
echo '   fruit:model = TimeCapsule' >> /opt/podman/samba/smb.conf
echo '   fruit:aapl = yes' >> /opt/podman/samba/smb.conf
echo '' >> /opt/podman/samba/smb.conf
echo '   # fix filenames with special chars (should be default)' >> /opt/podman/samba/smb.conf
echo '   mangled names = no' >> /opt/podman/samba/smb.conf
echo '   dos charset = CP850' >> /opt/podman/samba/smb.conf
echo '   unix charset = UTF-8' >> /opt/podman/samba/smb.conf
echo '' >> /opt/podman/samba/smb.conf
echo '[share]' >> /opt/podman/samba/smb.conf
echo '   browseable = yes' >> /opt/podman/samba/smb.conf
echo '   path = /data' >> /opt/podman/samba/smb.conf
echo '   read only = no' >> /opt/podman/samba/smb.conf
echo '   valid users = admin' >> /opt/podman/samba/smb.conf
echo '   write list = admin' >> /opt/podman/samba/smb.conf
echo
podman run -d --restart always \
  --name moci-samba \
  --network host \
  -v /data/share:/data \
  -v /opt/podman/samba/smb.conf:/etc/samba/smb.conf \
  -v /opt/podman/samba/users.conf:/etc/samba/users.conf \
  docker.io/dockurr/samba:latest

# setup share
mkdir -p /data/share
chmod 777 /data/share
chown -R nobody:nogroup /data/share
echo
echo '[global]' > /etc/samba/smb.conf
echo 'dns proxy = no' >> /etc/samba/smb.conf
echo 'encrypt passwords = yes' >> /etc/samba/smb.conf
echo 'log file = /var/log/samba/log.%m' >> /etc/samba/smb.conf
echo 'max log size = 1000' >> /etc/samba/smb.conf
echo 'netbios name = MYSERVER' >> /etc/samba/smb.conf
echo 'passdb backend = tdbsam' >> /etc/samba/smb.conf
echo 'security = user' >> /etc/samba/smb.conf
echo 'server string = moci-share Samba Server' >> /etc/samba/smb.conf
echo 'workgroup = WORKGROUP' >> /etc/samba/smb.conf
echo '' >> /etc/samba/smb.conf
echo '[share]' >> /etc/samba/smb.conf
echo 'browseable = yes' >> /etc/samba/smb.conf
echo 'create mask = 0770' >> /etc/samba/smb.conf
echo 'directory mask = 0770' >> /etc/samba/smb.conf
echo 'guest ok = no' >> /etc/samba/smb.conf
echo 'path = /data/share' >> /etc/samba/smb.conf
echo 'read list = readonly_user' >> /etc/samba/smb.conf
echo 'read only = no' >> /etc/samba/smb.conf
echo 'valid users = @admin root readonly_user' >> /etc/samba/smb.conf
echo 'write list = @admin root' >> /etc/samba/smb.conf
echo '' >> /etc/samba/smb.conf
echo '[public]' >> /etc/samba/smb.conf
echo 'browseable = yes' >> /etc/samba/smb.conf
echo 'create mask = 0666' >> /etc/samba/smb.conf
echo 'directory mask = 0777' >> /etc/samba/smb.conf
echo 'guest ok = yes' >> /etc/samba/smb.conf
echo 'path = /data/share/public' >> /etc/samba/smb.conf
echo 'read only = no' >> /etc/samba/smb.conf
echo '' >> /etc/samba/smb.conf
echo '[mail]' >> /etc/samba/smb.conf
echo 'browseable = yes' >> /etc/samba/smb.conf
echo 'create mask = 0770' >> /etc/samba/smb.conf
echo 'directory mask = 0770' >> /etc/samba/smb.conf
echo 'guest ok = no' >> /etc/samba/smb.conf
echo 'path = /data/share/mail' >> /etc/samba/smb.conf
echo 'read list = readonly_user' >> /etc/samba/smb.conf
echo 'read only = no' >> /etc/samba/smb.conf
echo 'valid users = exclusive_user root readonly_user' >> /etc/samba/smb.conf
echo 'write list = exclusive_user root' >> /etc/samba/smb.conf
echo





# setup user
mkdir -p /opt/share
useradd -ms /usr/bin/false share
openssl rand -hex 64 > /opt/share/share.key
passwd --stdin share < /opt/share/share.key


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
