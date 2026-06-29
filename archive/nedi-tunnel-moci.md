# `nedi-tunnel-moci`

## Details

- Site: Personal
- OS: Debian 13
- IPv4: `192.168.0.10`

Ports opened:

```
root@nedi-tunnel-moci:~# ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp on eth0             ALLOW IN    10.0.0.0/8
22/tcp on eth0             ALLOW IN    172.16.0.0/12
22/tcp on eth0             ALLOW IN    192.168.0.0/16
111 on eth0                ALLOW IN    10.0.0.0/8
111 on eth0                ALLOW IN    172.16.0.0/12
111 on eth0                ALLOW IN    192.168.0.0/16
2222/tcp on eth0           ALLOW IN    10.0.0.0/8
2222/tcp on eth0           ALLOW IN    172.16.0.0/12
2222/tcp on eth0           ALLOW IN    192.168.0.0/16
2333/tcp on eth0           ALLOW IN    10.0.0.0/8
2333/tcp on eth0           ALLOW IN    172.16.0.0/12
2333/tcp on eth0           ALLOW IN    192.168.0.0/16
2376/tcp on eth0           ALLOW IN    10.0.0.0/8
2376/tcp on eth0           ALLOW IN    172.16.0.0/12
2376/tcp on eth0           ALLOW IN    192.168.0.0/16
2377/tcp on eth0           ALLOW IN    10.0.0.0/8
2377/tcp on eth0           ALLOW IN    172.16.0.0/12
2377/tcp on eth0           ALLOW IN    192.168.0.0/16
2049 on eth0               ALLOW IN    10.0.0.0/8
2049 on eth0               ALLOW IN    172.16.0.0/12
2049 on eth0               ALLOW IN    192.168.0.0/16
20048 on eth0              ALLOW IN    10.0.0.0/8
20048 on eth0              ALLOW IN    172.16.0.0/12
20048 on eth0              ALLOW IN    192.168.0.0/16
32765 on eth0              ALLOW IN    10.0.0.0/8
32765 on eth0              ALLOW IN    172.16.0.0/12
32765 on eth0              ALLOW IN    192.168.0.0/16
```

## Initial system setup

```bash
# creates debian lxc
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/debian.sh)"
# wireguard
pct enter 1010

# sets up ssh server
cat << 'EOF' > /root/.ssh/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd 11753516+pedro-pereira-dev@users.noreply.github.com
EOF
cat << 'EOF' > /etc/ssh/sshd_config.d/sshd.conf
PasswordAuthentication no
X11Forwarding no
EOF
rm -f /etc/ssh/sshd_config.d/test.conf
systemctl restart ssh

# sets up ssh server port
mkdir -p /etc/systemd/system/ssh.socket.d
cat << 'EOF' > /etc/systemd/system/ssh.socket.d/override.conf
[Socket]
ListenStream=
ListenStream=2222
EOF
systemctl daemon-reload
systemctl restart ssh.socket

# disables ipv6 networking
cat << 'EOF' > /etc/sysctl.d/99-disable-ipv6.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
sysctl --system >/dev/null 2>&1

# sets up apt
rm -f /etc/apt/sources.list /etc/apt/sources.list~ /etc/apt/sources.list.bak
cat << EOF > /etc/apt/sources.list.d/debian.sources
Types: deb
URIs: http://deb.debian.org/debian/
Suites: trixie
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
$()
Types: deb
URIs: http://deb.debian.org/debian/
Suites: trixie-updates
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
$()
Types: deb
URIs: http://security.debian.org/debian-security/
Suites: trixie-security
Components: main
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF
cat << 'EOF' > /usr/bin/update
#!/bin/sh
apt update
apt full-upgrade -y
apt autoremove -y
EOF
chmod +x /usr/bin/update
update

# installs all required dependencies
apt install -y podman ufw wireguard

# sets up wireguard
apt install -y wireguard
wg genkey | tee /etc/wireguard/client.key | wg pubkey > /etc/wireguard/client.pub
cat << EOF > /etc/wireguard/wg0.conf
# server
[Interface]
Address = 10.10.10.10/32
PrivateKey = $(cat /etc/wireguard/client.key)
$()
# moci
[Peer]
AllowedIPs = 10.10.10.1/32
Endpoint = wireguard.boarede.com:61820
PublicKey = $(cat /etc/wireguard/client.pub)
EOF
systemctl enable wg-quick@wg0.service
systemctl daemon-reload
systemctl start wg-quick@wg0.service

# sets up podman socket
apt install -y podman
systemctl enable --now podman-restart.service podman.service podman.socket

# sets up socat
podman run -d --replace --restart always \
  --name nedi-tunnel-moci-ssh \
  --network host \
  --health-cmd='["nc", "-z", "10.10.10.1", "22"]' \
  --health-on-failure restart \
  docker.io/alpine/socat:latest \
    tcp-listen:22,fork,reuseaddr,tcp-keepidle=10,tcp-keepintvl=5,tcp-keepcnt=3 \
    tcp:10.10.10.1:22,tcp-keepidle=10,tcp-keepintvl=5,tcp-keepcnt=3
podman run -d --replace --restart always \
  --name nedi-tunnel-moci-rcp-tcp \
  --network host \
  --health-cmd='["nc", "-z", "10.10.10.1", "111"]' \
  --health-on-failure restart \
  docker.io/alpine/socat:latest \
    tcp-listen:111,fork,reuseaddr,tcp-keepidle=10,tcp-keepintvl=5,tcp-keepcnt=3 \
    tcp:10.10.10.1:111,tcp-keepidle=10,tcp-keepintvl=5,tcp-keepcnt=3
podman run -d --replace --restart always \
  --name nedi-tunnel-moci-rcp-udp \
  --network host \
  --health-cmd='["nc", "-z", "-u", "10.10.10.1", "111"]' \
  --health-on-failure restart \
  docker.io/alpine/socat:latest \
    UDP4-RECVFROM:111,fork \
    UDP4-SENDTO:10.10.10.1:111
podman run -d --replace --restart always \
  --name nedi-tunnel-moci-rathole \
  --network host \
  --health-cmd='["nc", "-z", "10.10.10.1", "2333"]' \
  --health-on-failure restart \
  docker.io/alpine/socat:latest \
    tcp-listen:2333,fork,reuseaddr,tcp-keepidle=10,tcp-keepintvl=5,tcp-keepcnt=3 \
    tcp:10.10.10.1:2333,tcp-keepidle=10,tcp-keepintvl=5,tcp-keepcnt=3
podman run -d --replace --restart always \
  --name neli-tunnel-moci-hawser-remote \
  --network host \
  --health-cmd='["nc", "-z", "10.10.10.1", "2376"]' \
  --health-on-failure restart \
  docker.io/alpine/socat:latest \
    tcp-listen:2376,fork,reuseaddr,tcp-keepidle=10,tcp-keepintvl=5,tcp-keepcnt=3 \
    tcp:10.10.10.1:2376,tcp-keepidle=10,tcp-keepintvl=5,tcp-keepcnt=3
podman run -d --replace --restart always \
  --name nedi-tunnel-moci-nfs-tcp \
  --network host \
  --health-cmd='["nc", "-z", "10.10.10.1", "2049"]' \
  --health-on-failure restart \
  docker.io/alpine/socat:latest \
    tcp-listen:2049,fork,reuseaddr,tcp-keepidle=10,tcp-keepintvl=5,tcp-keepcnt=3 \
    tcp:10.10.10.1:2049,tcp-keepidle=10,tcp-keepintvl=5,tcp-keepcnt=3
podman run -d --replace --restart always \
  --name nedi-tunnel-moci-nfs-udp \
  --network host \
  --health-cmd='["nc", "-z", "-u", "10.10.10.1", "2049"]' \
  --health-on-failure restart \
  docker.io/alpine/socat:latest \
    UDP4-RECVFROM:2049,fork \
    UDP4-SENDTO:10.10.10.1:2049
podman run -d --replace --restart always \
  --name nedi-tunnel-moci-mountd-tcp \
  --network host \
  --health-cmd='["nc", "-z", "10.10.10.1", "20048"]' \
  --health-on-failure restart \
  docker.io/alpine/socat:latest \
    tcp-listen:20048,fork,reuseaddr,tcp-keepidle=10,tcp-keepintvl=5,tcp-keepcnt=3 \
    tcp:10.10.10.1:20048,tcp-keepidle=10,tcp-keepintvl=5,tcp-keepcnt=3
podman run -d --replace --restart always \
  --name nedi-tunnel-moci-mountd-udp \
  --network host \
  --health-cmd='["nc", "-z", "-u", "10.10.10.1", "20048"]' \
  --health-on-failure restart \
  docker.io/alpine/socat:latest \
    UDP4-RECVFROM:20048,fork \
    UDP4-SENDTO:10.10.10.1:20048
podman run -d --replace --restart always \
  --name nedi-tunnel-moci-statd-tcp \
  --network host \
  --health-cmd='["nc", "-z", "10.10.10.1", "32765"]' \
  --health-on-failure restart \
  docker.io/alpine/socat:latest \
    tcp-listen:32765,fork,reuseaddr,tcp-keepidle=10,tcp-keepintvl=5,tcp-keepcnt=3 \
    tcp:10.10.10.1:32765,tcp-keepidle=10,tcp-keepintvl=5,tcp-keepcnt=3
podman run -d --replace --restart always \
  --name nedi-tunnel-moci-statd-udp \
  --network host \
  --health-cmd='["nc", "-z", "-u", "10.10.10.1", "32765"]' \
  --health-on-failure restart \
  docker.io/alpine/socat:latest \
    UDP4-RECVFROM:32765,fork \
    UDP4-SENDTO:10.10.10.1:32765

# sets up hawser
mkdir -p /opt/podman/hawser
openssl rand -hex 64 > /opt/podman/hawser/token.key
podman run -d --replace --restart always \
  --name nedi-tunnel-moci-hawser \
  --network host \
  -e PORT=2377 \
  -e STACKS_DIR=/etc/hawser \
  -e TOKEN=$(cat /opt/podman/hawser/token.key) \
  -v /opt/podman/hawser:/etc/hawser \
  -v /run/podman/podman.sock:/var/run/docker.sock \
  --health-on-failure restart \
  ghcr.io/finsys/hawser:latest

# sets up firewall
apt install -y ufw
ufw default allow outgoing
ufw default deny incoming
# SSH - moci
ufw allow in on eth0 from 10.0.0.0/8 to any port 22 proto tcp
ufw allow in on eth0 from 172.16.0.0/12 to any port 22 proto tcp
ufw allow in on eth0 from 192.168.0.0/16 to any port 22 proto tcp
# RCP - moci
ufw allow in on eth0 from 10.0.0.0/8 to any port 111
ufw allow in on eth0 from 172.16.0.0/12 to any port 111
ufw allow in on eth0 from 192.168.0.0/16 to any port 111
# SSH
ufw allow in on eth0 from 10.0.0.0/8 to any port 2222 proto tcp
ufw allow in on eth0 from 172.16.0.0/12 to any port 2222 proto tcp
ufw allow in on eth0 from 192.168.0.0/16 to any port 2222 proto tcp
# Rathole - moci
ufw allow in on eth0 from 10.0.0.0/8 to any port 2333 proto tcp
ufw allow in on eth0 from 172.16.0.0/12 to any port 2333 proto tcp
ufw allow in on eth0 from 192.168.0.0/16 to any port 2333 proto tcp
# Hawser - moci
ufw allow in on eth0 from 10.0.0.0/8 to any port 2376 proto tcp
ufw allow in on eth0 from 172.16.0.0/12 to any port 2376 proto tcp
ufw allow in on eth0 from 192.168.0.0/16 to any port 2376 proto tcp
# Hawser
ufw allow in on eth0 from 10.0.0.0/8 to any port 2377 proto tcp
ufw allow in on eth0 from 172.16.0.0/12 to any port 2377 proto tcp
ufw allow in on eth0 from 192.168.0.0/16 to any port 2377 proto tcp
# NFS - moci
ufw allow in on eth0 from 10.0.0.0/8 to any port 2049
ufw allow in on eth0 from 172.16.0.0/12 to any port 2049
ufw allow in on eth0 from 192.168.0.0/16 to any port 2049
# Mountd - moci
ufw allow in on eth0 from 10.0.0.0/8 to any port 20048
ufw allow in on eth0 from 172.16.0.0/12 to any port 20048
ufw allow in on eth0 from 192.168.0.0/16 to any port 20048
# Statd - moci
ufw allow in on eth0 from 10.0.0.0/8 to any port 32765
ufw allow in on eth0 from 172.16.0.0/12 to any port 32765
ufw allow in on eth0 from 192.168.0.0/16 to any port 32765
ufw enable

```
