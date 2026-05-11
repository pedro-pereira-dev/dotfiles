# `moci-tunnel-server`

## Details

- Cloud: Oracle
- OS: Debian 13
- IPv4: `10.11.12.10`

Ports opened:

```
root@moci-tunnel-server:~# ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), deny (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp on eth0             ALLOW IN    10.0.0.0/8
22/tcp on eth0             ALLOW IN    172.16.0.0/12
22/tcp on eth0             ALLOW IN    192.168.0.0/16
2333/tcp on eth0           ALLOW IN    10.0.0.0/8
2333/tcp on eth0           ALLOW IN    172.16.0.0/12
2333/tcp on eth0           ALLOW IN    192.168.0.0/16
2376/tcp on eth0           ALLOW IN    10.0.0.0/8
2376/tcp on eth0           ALLOW IN    172.16.0.0/12
2376/tcp on eth0           ALLOW IN    192.168.0.0/16
61820/udp on eth0          ALLOW IN    Anywhere
```

## Initial system setup

```bash
# setup basic container
bash -c "$(curl -fsSL https://raw.githubusercontent.com/asylumexp/Proxmox/main/ct/debian.sh)"
pct enter 1010

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
apt install -y crun podman ufw wireguard

# setup wireguard
apt install -y ufw wireguard
sed -i 's/^#\(net\/ipv4\/ip_forward=1\)/\1/' /etc/ufw/sysctl.conf
(cd /etc/wireguard; umask 077; cd)
wg genkey | tee /etc/wireguard/server.key | wg pubkey > /etc/wireguard/server.pub
echo
echo '[Interface]' > /etc/wireguard/wg0.conf
echo 'Address = 10.11.13.10/24' >> /etc/wireguard/wg0.conf
echo 'ListenPort = 61820' >> /etc/wireguard/wg0.conf
echo "PrivateKey = $(cat /etc/wireguard/server.key)" >> /etc/wireguard/wg0.conf
echo '' >> /etc/wireguard/wg0.conf
echo 'PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE' >> /etc/wireguard/wg0.conf
echo 'PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE' >> /etc/wireguard/wg0.conf
echo '' >> /etc/wireguard/wg0.conf
echo '#[Peer]' >> /etc/wireguard/wg0.conf
echo '#AllowedIPs = 10.11.13.11/32' >> /etc/wireguard/wg0.conf
echo '#PublicKey = ' >> /etc/wireguard/wg0.conf
echo
systemctl enable wg-quick@wg0.service
systemctl daemon-reload
systemctl start wg-quick@wg0

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
echo '[server.services.nedi-proxy-http]' >> /opt/podman/rathole/server.toml
echo 'bind_addr = "0.0.0.0:80"' >> /opt/podman/rathole/server.toml
echo '[server.services.nedi-proxy-https]' >> /opt/podman/rathole/server.toml
echo 'bind_addr = "0.0.0.0:443"' >> /opt/podman/rathole/server.toml
echo
podman run -d --restart always \
  --name moci-tunnel-server-rathole \
  --network host \
  -v /opt/podman/rathole/server.toml:/server.toml \
  ghcr.io/rathole-org/rathole:dev /server.toml

# setup hawser
mkdir -p /opt/podman/hawser
podman run -d --restart always \
  --name moci-tunnel-server-hawser \
  --network host \
  -e STACKS_DIR=/etc/hawser \
  -e TOKEN=$(openssl rand -hex 64) \
  -v /opt/podman/hawser:/etc/hawser \
  -v /run/podman/podman.sock:/var/run/docker.sock \
  ghcr.io/finsys/hawser:latest
podman inspect --format='{{range .Config.Env}}{{println .}}{{end}}' moci-tunnel-server-hawser | grep TOKEN | cut -d= -f2

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
# rathole - 3333
ufw allow in on eth0 from 10.0.0.0/8 to any port 2333 proto tcp
ufw allow in on eth0 from 172.16.0.0/12 to any port 2333 proto tcp
ufw allow in on eth0 from 192.168.0.0/16 to any port 2333 proto tcp
# wireguard - 61820
ufw allow in on eth0 to any port 61820 proto udp
ufw enable

```
