# `neli-tunnel-moci-pihole`

## Details

- Site: Personal
- OS: Debian 13
- IPv4: `192.168.0.4`

Ports opened:

```
root@neli-tunnel-moci-pihole:~# ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), deny (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    10.0.0.0/8
22/tcp                     ALLOW IN    172.16.0.0/12
22/tcp                     ALLOW IN    192.168.0.0/16
80/tcp                     ALLOW IN    10.0.0.0/8
80/tcp                     ALLOW IN    172.16.0.0/12
80/tcp                     ALLOW IN    192.168.0.0/16
2222/tcp                   ALLOW IN    10.0.0.0/8
2222/tcp                   ALLOW IN    172.16.0.0/12
2222/tcp                   ALLOW IN    192.168.0.0/16
2376/tcp                   ALLOW IN    10.0.0.0/8
2376/tcp                   ALLOW IN    172.16.0.0/12
2376/tcp                   ALLOW IN    192.168.0.0/16
2377/tcp                   ALLOW IN    10.0.0.0/8
2377/tcp                   ALLOW IN    172.16.0.0/12
2377/tcp                   ALLOW IN    192.168.0.0/16
```

## Initial system setup

```bash
# setup basic container
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/debian.sh)"
pct enter 1004

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
echo 'Address = 10.1.10.4/32' >> /etc/wireguard/wg0.conf
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
  --name neli-tunnel-moci-pihole-ssh \
  --network host \
  --health-cmd='["nc", "-z", "10.0.10.4", "22"]' \
  --health-on-failure restart \
  docker.io/alpine/socat:latest \
    tcp-listen:22,fork,reuseaddr,tcp-keepidle=10,tcp-keepintvl=5,tcp-keepcnt=3 \
    tcp:10.0.10.4:22,tcp-keepidle=10,tcp-keepintvl=5,tcp-keepcnt=3
podman run -d --restart always \
  --name neli-tunnel-moci-pihole \
  --network host \
  --health-cmd='["nc", "-z", "10.0.10.4", "80"]' \
  --health-on-failure restart \
  docker.io/alpine/socat:latest \
    tcp-listen:80,fork,reuseaddr,tcp-keepidle=10,tcp-keepintvl=5,tcp-keepcnt=3 \
    tcp:10.0.10.4:80,tcp-keepidle=10,tcp-keepintvl=5,tcp-keepcnt=3
podman run -d --restart always \
  --name neli-tunnel-moci-pihole-hawser-remote \
  --network host \
  --health-cmd='["nc", "-z", "10.0.10.4", "2376"]' \
  --health-on-failure restart \
  docker.io/alpine/socat:latest \
    tcp-listen:2376,fork,reuseaddr,tcp-keepidle=10,tcp-keepintvl=5,tcp-keepcnt=3 \
    tcp:10.0.10.4:2376,tcp-keepidle=10,tcp-keepintvl=5,tcp-keepcnt=3

# setup rathole
mkdir -p /opt/podman/rathole
echo
echo '[client]' > /opt/podman/rathole/client.toml
echo 'remote_addr = "10.0.10.4:3333"' >> /opt/podman/rathole/client.toml
echo 'default_token = ""' >> /opt/podman/rathole/client.toml
echo '' >> /opt/podman/rathole/client.toml
echo '[client.services.neli-pihole]' >> /opt/podman/rathole/client.toml
echo 'local_addr = "192.168.0.2:80"' >> /opt/podman/rathole/client.toml
echo
podman run -d --restart always \
  --name neli-pihole-rathole \
  --network host \
  --health-cmd='["/app/rathole", "--version"]' \
  --health-on-failure restart \
  -v /opt/podman/rathole/client.toml:/client.toml \
  ghcr.io/rathole-org/rathole:dev /client.toml

# setup hawser
mkdir -p /opt/podman/hawser
openssl rand -hex 64 > /opt/podman/hawser/token.key
podman run -d --restart always \
  --name neli-tunnel-moci-pihole-hawser \
  --network host \
  -e PORT=2377 \
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
# SSH - moci-pihole
ufw allow from 10.0.0.0/8 to any port 22 proto tcp
ufw allow from 172.16.0.0/12 to any port 22 proto tcp
ufw allow from 192.168.0.0/16 to any port 22 proto tcp
# Pihole - moci-pihole
ufw allow from 10.0.0.0/8 to any port 80 proto tcp
ufw allow from 172.16.0.0/12 to any port 80 proto tcp
ufw allow from 192.168.0.0/16 to any port 80 proto tcp
# SSH
ufw allow from 10.0.0.0/8 to any port 2222 proto tcp
ufw allow from 172.16.0.0/12 to any port 2222 proto tcp
ufw allow from 192.168.0.0/16 to any port 2222 proto tcp
# Hawser - moci-pihole
ufw allow from 10.0.0.0/8 to any port 2376 proto tcp
ufw allow from 172.16.0.0/12 to any port 2376 proto tcp
ufw allow from 192.168.0.0/16 to any port 2376 proto tcp
# Hawser
ufw allow from 10.0.0.0/8 to any port 2377 proto tcp
ufw allow from 172.16.0.0/12 to any port 2377 proto tcp
ufw allow from 192.168.0.0/16 to any port 2377 proto tcp
ufw enable

```
