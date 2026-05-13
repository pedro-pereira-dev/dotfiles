# `neli-tunnel-moci`

## Details

- Site: Personal
- OS: Debian 13
- IPv4: `192.168.0.33`

Ports opened:

```
root@neli-tunnel-moci:~# ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), deny (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    10.0.0.0/8
22/tcp                     ALLOW IN    172.16.0.0/12
22/tcp                     ALLOW IN    192.168.0.0/16
2222/tcp                   ALLOW IN    10.0.0.0/8
2222/tcp                   ALLOW IN    172.16.0.0/12
2222/tcp                   ALLOW IN    192.168.0.0/16
2377/tcp                   ALLOW IN    10.0.0.0/8
2377/tcp                   ALLOW IN    172.16.0.0/12
2377/tcp                   ALLOW IN    192.168.0.0/16
8006/tcp                   ALLOW IN    10.0.0.0/8
8006/tcp                   ALLOW IN    172.16.0.0/12
8006/tcp                   ALLOW IN    192.168.0.0/16
```

## Initial system setup

```bash
# setup basic container
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/debian.sh)"
pct enter 1033

# setup ssh
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd 11753516+pedro-pereira-dev@users.noreply.github.com' > /root/.ssh/authorized_keys
echo 'PasswordAuthentication no' > /etc/ssh/sshd_config.d/sshd.conf
echo 'X11Forwarding no' >> /etc/ssh/sshd_config.d/sshd.conf
systemctl restart ssh
mkdir -p /etc/systemd/system/ssh.socket.d
echo '[Socket]' > /etc/systemd/system/ssh.socket.d/override.conf
echo 'ListenStream=' >> /etc/systemd/system/ssh.socket.d/override.conf
echo 'ListenStream=2222' >> /etc/systemd/system/ssh.socket.d/override.conf
systemctl daemon-reload
systemctl restart ssh.socket

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
apt install -y crun podman ufw wireguard

# setup wireguard
apt install -y ufw wireguard
sed -i 's/^#\(net\/ipv4\/ip_forward=1\)/\1/' /etc/ufw/sysctl.conf
(cd /etc/wireguard; umask 077; cd)
wg genkey | tee /etc/wireguard/client.key | wg pubkey > /etc/wireguard/client.pub
echo
echo '[Interface]' > /etc/wireguard/wg0.conf
echo 'Address = 10.1.10.33/32' >> /etc/wireguard/wg0.conf
echo "PrivateKey = $(cat /etc/wireguard/client.key)" >> /etc/wireguard/wg0.conf
echo '' >> /etc/wireguard/wg0.conf
echo '#[Peer]' >> /etc/wireguard/wg0.conf
echo '#AllowedIPs = 10.1.10.1/32, 10.0.10.0/24' >> /etc/wireguard/wg0.conf
echo '#Endpoint = wireguard.boarede.com:61820' >> /etc/wireguard/wg0.conf
echo '#PublicKey = ' >> /etc/wireguard/wg0.conf
echo
systemctl enable wg-quick@wg0.service
systemctl daemon-reload
systemctl start wg-quick@wg0

# setup podman
apt install -y crun podman
systemctl enable --now podman-restart.service podman.service podman.socket

# setup socat
podman run -d --restart always \
  --name neli-tunnel-moci-ssh \
  --network host \
  --health-cmd='["nc", "-z", "10.0.10.1", "22"]' \
  --health-on-failure restart \
  docker.io/alpine/socat:latest tcp-listen:22,fork,reuseaddr tcp:10.0.10.1:22
podman run -d --restart always \
  --name neli-tunnel-moci \
  --network host \
  --health-cmd='["nc", "-z", "10.0.10.1", "8006"]' \
  --health-on-failure restart \
  docker.io/alpine/socat:latest tcp-listen:8006,fork,reuseaddr tcp:10.0.10.1:8006

# setup hawser
mkdir -p /opt/podman/hawser
podman run -d --restart always \
  --name neli-tunnel-moci-hawser \
  --network host \
  -e PORT=2377 \
  -e STACKS_DIR=/etc/hawser \
  -e TOKEN=$(openssl rand -hex 64) \
  -v /opt/podman/hawser:/etc/hawser \
  -v /run/podman/podman.sock:/var/run/docker.sock \
  --health-on-failure restart \
  ghcr.io/finsys/hawser:latest
podman inspect --format='{{range .Config.Env}}{{println .}}{{end}}' neli-tunnel-moci-hawser | grep TOKEN | cut -d= -f2

# setup firewall
apt install -y ufw
ufw default allow outgoing
ufw default deny incoming
# SSH - moci
ufw allow from 10.0.0.0/8 to any port 22 proto tcp
ufw allow from 172.16.0.0/12 to any port 22 proto tcp
ufw allow from 192.168.0.0/16 to any port 22 proto tcp
# SSH
ufw allow from 10.0.0.0/8 to any port 2222 proto tcp
ufw allow from 172.16.0.0/12 to any port 2222 proto tcp
ufw allow from 192.168.0.0/16 to any port 2222 proto tcp
# Hawser
ufw allow from 10.0.0.0/8 to any port 2377 proto tcp
ufw allow from 172.16.0.0/12 to any port 2377 proto tcp
ufw allow from 192.168.0.0/16 to any port 2377 proto tcp
# Proxmox - moci
ufw allow from 10.0.0.0/8 to any port 8006 proto tcp
ufw allow from 172.16.0.0/12 to any port 8006 proto tcp
ufw allow from 192.168.0.0/16 to any port 8006 proto tcp
ufw enable

```
