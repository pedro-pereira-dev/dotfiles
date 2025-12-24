# dotfiles

My custom system dotfiles - *_WORK IN PROGRESS_*

## Linux

```bash
curl -Lfs -- https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/dots.sh | sh -s -- install


bash <(wget -qO - https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/dots)

curl -Lfs https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/dots | sh -s -- install ...
```

## Keys

Encrypt and decrypt:

```bash
gpg --pinentry-mode loopback --symmetric input.tar
gpg --pinentry-mode loopback --decrypt input.tar.gpg > output.tar
```

Tar and untar:

```bash
tar -czvf output.tar directory
tar -xvf input.tar
```

    MAKEOPTS equal to CPU core count plus 1 (or RAM limit), Emerge jobs set to half that number rounded up, both with a load average limit set to 1 more than the number of Make jobs specified in MAKEOPTS.

or

    MAKEOPTS set to some specific lower number, optionally with a load average limit set to the CPU core count (or RAM limit), and Emerge jobs not set (which will give you the default of 1 job).

### Notes

```sh
# define port_https = 8080
#
# table inet default {
#   set banned { flags dynamic, timeout; gc-interval 5m; size 65536; timeout 12h; type ipv4_addr; }
#
#   chain forward { type filter hook forward priority filter; policy drop; }
#   chain output { type filter hook output priority filter; policy accept; }
#
#   chain prerouting {
#     type nat hook prerouting priority dstnat
#     policy accept
#
#     tcp dport 443 redirect to $port_https
#   }
#   chain input {
#     type filter hook input priority filter
#     policy drop
#
#     ct state { established,related } accept
#     iif lo accept
#
#     ct state invalid drop
#     iif != lo ip daddr 127.0.0.0/8 drop
#     ip frag-off & 0x3fff != 0 drop
#     ip saddr @banned drop
#
#     icmp type echo-request limit rate 2/second burst 4 packets accept
#     icmp type { destination-unreachable,echo-reply,time-exceeded } accept
#
#     tcp dport 22 ct state new limit rate 2/minute burst 4 packets accept
#     tcp dport 22 ct state new add @banned { ip saddr } drop
#
#     tcp dport $port_https ct status dnat limit rate 32/second burst 64 packets accept
#   }
# }
```

```bash
DuckDNS_Token="token" acme.sh --dns dns_duckdns --domain '*.remote-4620.duckdns.org' --issue
cat \*.remote-4620.duckdns.org.key fullchain.cer > remote-4620.duckdns.org.pem

# placeholder values
export SPACESHIP_API_KEY='8azEY0VMllj859ZqepH7'
export SPACESHIP_API_SECRET='JkZcYYVvSgwSAOXugXrBZ38nbhcanwiZvYP1MtTu0erI32Vmdxtcxn0tTGGL7SGW'
export SPACESHIP_ROOT_DOMAIN='(Optional) <Manually specify the root domain if auto-detection fails>'

podman run --rm neilpang/acme.sh
./acme.sh --issue --dns dns_spaceship -d example.domain.com



git-crypt init
git-crypt export-key key.bin
gpg --pinentry-mode loopback --symmetric key.bin

gpg --pinentry-mode loopback -d key.bin.gpg > key.bin
git-crypt unlock key.bin
```

https://tonsky.me/blog/syntax-highlighting/

#### Setup Oracle VPS

- Create virtual network with default parameters.
- Create compute instance using default parameters, but changing the shape to ampere 4 cpu 24 gb mem and using ubuntu.
- Connect with the ssh key pair into the instance and change the ubuntu user password with:
```bash
sudo su
passwd ubuntu
```
- Open cloud shell connection on: Compute > <select instance> > OS Management > Console connection > Launch Cloud Shell connection and run:
```bash
sudo su
cd /boot/efi
wget https://boot.netboot.xyz/ipxe/netboot.xyz-arm64.efi
```
- Reboot and press ESC repeatdly until the UEFI shell appear then choose Boot Maintenance Manager > Boot From File > search for the netboot file
- Choose Linux Network Installers > Alpine > Login as root with not password and setup environment:
```bash
echo 'auto eth0' > /etc/network/interfaces
echo 'iface eth0 inet dhcp' >> /etc/network/interfaces
/etc/init.d/networking restart
ping -c 3 gentoo.org
setup-sshd # type 'yes' to 'Allow root ssh login?'
passwd
```
- Login with ssh to root@<ip> and setup installation:
```bash
setup-apkrepos -1 && apk update
apk add curl dosfstools e2fsprogs tar util-linux xz
curl -Lfs -- https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/install-gentoo.sh |

sh -s -- --hostname gs-home --password root
sh -s -- --hostname gs-proxy --password root
```

[Source](https://gist.github.com/amishmm/e2dc93e65cf79116f2ef2d542f05e61b)
[authelia haproxy](https://gist.github.com/matejaputic/52a0716da980f992800ba53202274884)
