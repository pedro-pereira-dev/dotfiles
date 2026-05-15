# dotfiles

My custom system dotfiles - *_WORK IN PROGRESS_*

## Proxmox

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/pedro-pereira-dev/dotfiles/refs/heads/main/restore-host-from)"
```

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

### Misc stuff

[Source](https://gist.github.com/amishmm/e2dc93e65cf79116f2ef2d542f05e61b)
[authelia haproxy](https://gist.github.com/matejaputic/52a0716da980f992800ba53202274884)
https://tonsky.me/blog/syntax-highlighting/

arch: amd64
cores: 2
features: nesting=1,fuse=1
hostname: pve1-nas
memory: 2048
net0: name=eth0,bridge=vmbr0,gw=192.168.0.1,hwaddr=BC:24:11:48:20:D1,ip=192.168.0.30/24,type=veth
onboot: 1
ostype: debian
rootfs: data:vm-1030-disk-0,size=8G
snaptime: 1775596478
swap: 512
tags: nas;network
timezone: Europe/Lisbon
lxc.cgroup2.devices.allow: a
lxc.cap.drop:
lxc.cgroup2.devices.allow: b 8:* rwm
lxc.cgroup2.devices.allow: c 188:* rwm
lxc.cgroup2.devices.allow: c 189:* rwm
lxc.mount.entry: /dev/sda           dev/sda           none bind,optional,create=file
lxc.mount.entry: /dev/sda1          dev/sda1          none bind,optional,create=file
lxc.mount.entry: /dev/sdc           dev/sdc           none bind,optional,create=file
lxc.mount.entry: /dev/sdc1          dev/sdc1          none bind,optional,create=file
lxc.mount.entry: /dev/sdd           dev/sdd           none bind,optional,create=file
lxc.mount.entry: /dev/sdd1          dev/sdd1          none bind,optional,create=file
lxc.mount.entry: /dev/serial/by-id  dev/serial/by-id  none bind,optional,create=dir
lxc.mount.entry: /dev/ttyACM0       dev/ttyACM0       none bind,optional,create=file
lxc.mount.entry: /dev/ttyACM1       dev/ttyACM1       none bind,optional,create=file
lxc.mount.entry: /dev/ttyUSB0       dev/ttyUSB0       none bind,optional,create=file
lxc.mount.entry: /dev/ttyUSB1       dev/ttyUSB1       none bind,optional,create=file

### https://github.com/DoTheEvo/NAS-MergerFS-SnapRAID

UUID=785deb18-6f84-4821-b181-9a2b236a9919 /mnt/pool/fast-disk-01 ext4 defaults 0 0
UUID=d24931cf-c8c5-49c4-aa61-2d46699d5a05 /mnt/pool/slow-disk-01 ext4 defaults 0 0
UUID=4d3499fd-cec2-41bf-afd1-55ebd3f260b0 /mnt/pool/parity-disk-01 ext4 defaults 0 0

/mnt/pool/fast-disk-* /mnt/storage/fast mergerfs defaults 0 0
/mnt/pool/slow-disk-* /mnt/storage/slow mergerfs defaults 0 0
/mnt/pool/fast-disk-*:/mnt/pool/slow-disk-* /mnt/storage/data mergerfs defaults,category.create=ff 0 0

----

autosave 64

disk fast-disk-01 /mnt/pool/fast-disk-01
disk slow-disk-01 /mnt/pool/slow-disk-01

content /mnt/pool/.snapraid.content
content /mnt/pool/fast-disk-01/.snapraid.content
content /mnt/pool/slow-disk-01/.snapraid.content

parity /mnt/pool/parity-disk-01/.snapraid.parity

----

nano /etc/systemd/system/maintain-snapraid.service

[Unit]
Description=Mantains snapraid disk array

[Service]
Type=oneshot
ExecStart=/etc/bin.d/maintain-snapraid.sh

----

nano /etc/systemd/system/maintain-snapraid.timer

[Unit]
Description=Run snapraid disk array maintenance at a random time each day

[Timer]
OnCalendar=daily
RandomizedDelaySec=24h
Persistent=true

[Install]
WantedBy=timers.target

----

nano /etc/systemd/system/hdds-spindown-enabled.service

[Unit]
Description=Spindown all hdd devices after one hour idle
After=local-fs.target systemd-udev-settle.service

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'for d in /sys/block/sd*; do [ -f "$d/queue/rotational" ] && [ "$(cat $d/queue/rotational)" -eq 1 ] && [ -b "/dev/$(basename $d)" ] && /usr/bin/hdparm -S 242 -B 127 /dev/$(basename $d) 2>/dev/null || true; done'

[Install]
WantedBy=multi-user.target
