# `neli`

## Details

- Site: Personal
- OS: Debian 13 / Proxmox 9
- IPv4: `192.168.0.31`

```
root@neli:~# lsblk -o NAME,FSTYPE,UUID,SIZE,FSAVAIL,MOUNTPOINTS
NAME                         FSTYPE      UUID                                     SIZE FSAVAIL MOUNTPOINTS
nvme0n1                                                                         476.9G
├─nvme0n1p1                  vfat        BA7D-1785                                 63M   57.6M /boot/efi
└─nvme0n1p2                  LVM2_member 4yUXAd-yubY-RIpf-hcPP-7Asc-i1K9-bLuUoN 476.9G
  ├─vg-swap                  swap        a90ccdcf-faa3-45d3-9df9-f9497c749465       1G         [SWAP]
  ├─vg-root                  ext4        fce85cc7-3e77-4b8f-a839-f83072d02bf2      16G   10.3G /
  ├─vg-data_tmeta                                                                 116M
  │ └─vg-data-tpool                                                             459.6G
  └─vg-data_tdata                                                               459.6G
    └─vg-data-tpool                                                             459.6G
```

Ports opened:

```
root@neli:~# ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    10.0.0.0/8
22/tcp                     ALLOW IN    172.16.0.0/12
22/tcp                     ALLOW IN    192.168.0.0/16
8006/tcp                   ALLOW IN    10.0.0.0/8
8006/tcp                   ALLOW IN    172.16.0.0/12
8006/tcp                   ALLOW IN    192.168.0.0/16
```

## Initial system setup

```bash

# setup ssh
echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJbHkOpoucRSqD/zKiyC2xtjw0F/JeUtZlrmMuLy2iWd 11753516+pedro-pereira-dev@users.noreply.github.com' > /root/.ssh/authorized_keys
echo 'PasswordAuthentication no' > /etc/ssh/sshd_config.d/sshd.conf
echo 'X11Forwarding no' >> /etc/ssh/sshd_config.d/sshd.conf
systemctl restart ssh

# setup fstab
echo 'UUID=BA7D-1785          /boot/efi       vfat defaults,noatime,nodev,noexec,nosuid,umask=0077 0 2' > /etc/fstab
echo '/dev/mapper/vg-root     /               ext4 defaults,errors=remount-ro 0 1' >> /etc/fstab
echo '/dev/mapper/vg-swap     none            swap sw 0 0' >> /etc/fstab

# disable ipv6
echo 'net.ipv6.conf.all.disable_ipv6 = 1' > /etc/sysctl.d/99-disable-ipv6.conf
echo 'net.ipv6.conf.default.disable_ipv6 = 1' >> /etc/sysctl.d/99-disable-ipv6.conf
echo 'net.ipv6.conf.lo.disable_ipv6 = 1' >> /etc/sysctl.d/99-disable-ipv6.conf
sysctl --system

# setup grub
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 ipv6.disable=1"/' /etc/default/grub
update-grub

# setup apt
apt install -y curl
rm -f /etc/apt/sources.list /etc/apt/sources.list~ /etc/apt/sources.list.bak
curl -L https://enterprise.proxmox.com/debian/proxmox-archive-keyring-trixie.gpg -o /usr/share/keyrings/proxmox-archive-keyring.gpg
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
echo 'Types: deb' > /etc/apt/sources.list.d/pve-install-repo.sources
echo 'URIs: http://download.proxmox.com/debian/pve' >> /etc/apt/sources.list.d/pve-install-repo.sources
echo 'Suites: trixie' >> /etc/apt/sources.list.d/pve-install-repo.sources
echo 'Components: pve-no-subscription' >> /etc/apt/sources.list.d/pve-install-repo.sources
echo 'Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg' >> /etc/apt/sources.list.d/pve-install-repo.sources
echo
apt update
apt full-upgrade -y

# setup proxmox kernel
apt install -y proxmox-default-kernel
systemctl reboot

# setup proxmox dependencies
apt install -y proxmox-ve postfix open-iscsi chrony
# choose local only and leave the system name as is
apt remove -y linux-image-amd64 'linux-image-6.12*'
update-grub
apt remove -y os-prober

# setup update scripts
echo
echo '#!/bin/sh' > /usr/bin/update
echo 'apt update' >> /usr/bin/update
echo 'apt full-upgrade -y' >> /usr/bin/update
echo 'apt autoremove -y' >> /usr/bin/update
echo
chmod +x /usr/bin/update

# setup storage
lvcreate -l 100%FREE --thinpool data vg

# run proxmox helper scripts
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/microcode.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/post-pve-install.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/kernel-clean.sh)"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/scaling-governor.sh)"

# disable backlight
systemctl mask systemd-backlight@backlight:intel_backlight.service
systemctl stop systemd-backlight@backlight:intel_backlight.service
echo
echo '[Unit]' > /etc/systemd/system/disable-backlight.service
echo 'Description=Disable Backlight at Boot' >> /etc/systemd/system/disable-backlight.service
echo 'After=multi-user.target' >> /etc/systemd/system/disable-backlight.service
echo '' >> /etc/systemd/system/disable-backlight.service
echo '[Service]' >> /etc/systemd/system/disable-backlight.service
echo 'Type=oneshot' >> /etc/systemd/system/disable-backlight.service
echo "ExecStart=/usr/bin/sh -c 'for d in /sys/class/backlight/*; do echo 0 > \"\$d/brightness\"; done'" >> /etc/systemd/system/disable-backlight.service
echo 'RemainAfterExit=yes' >> /etc/systemd/system/disable-backlight.service
echo '' >> /etc/systemd/system/disable-backlight.service
echo '[Install]' >> /etc/systemd/system/disable-backlight.service
echo 'WantedBy=multi-user.target' >> /etc/systemd/system/disable-backlight.service
echo
systemctl enable disable-backlight.service
systemctl daemon-reload
systemctl start disable-backlight.service

# disable lid
mkdir -p /etc/systemd/logind.conf.d/
echo
echo '[Login]' > /etc/systemd/logind.conf.d/lid.conf
echo 'HandleLidSwitch=ignore' >> /etc/systemd/logind.conf.d/lid.conf
echo 'HandleLidSwitchExternalPower=ignore' >> /etc/systemd/logind.conf.d/lid.conf
echo 'HandleLidSwitchDocked=ignore' >> /etc/systemd/logind.conf.d/lid.conf
echo
systemctl restart systemd-logind

# setup autoaspm
echo '#!/usr/bin/env python3' > /usr/bin/autoaspm
echo '' >> /usr/bin/autoaspm
echo '# Original bash script by Luis R. Rodriguez' >> /usr/bin/autoaspm
echo '# Re-written in Python by z8' >> /usr/bin/autoaspm
echo '# Re-re-written to patch supported devices automatically by notthebee' >> /usr/bin/autoaspm
echo '' >> /usr/bin/autoaspm
echo 'import re' >> /usr/bin/autoaspm
echo 'import subprocess' >> /usr/bin/autoaspm
echo 'import os' >> /usr/bin/autoaspm
echo 'import platform' >> /usr/bin/autoaspm
echo 'from enum import Enum' >> /usr/bin/autoaspm
echo '' >> /usr/bin/autoaspm
echo 'class ASPM(Enum):' >> /usr/bin/autoaspm
echo '    DISABLED = 0b00' >> /usr/bin/autoaspm
echo '    L0s = 0b01' >> /usr/bin/autoaspm
echo '    L1 = 0b10' >> /usr/bin/autoaspm
echo '    L0sL1 = 0b11' >> /usr/bin/autoaspm
echo '' >> /usr/bin/autoaspm
echo '' >> /usr/bin/autoaspm
echo 'def run_prerequisites():' >> /usr/bin/autoaspm
echo '    if platform.system() != "Linux":' >> /usr/bin/autoaspm
echo '        raise OSError("This script only runs on Linux-based systems")' >> /usr/bin/autoaspm
echo '    if not os.environ.get("SUDO_UID") and os.geteuid() != 0:' >> /usr/bin/autoaspm
echo '        raise PermissionError("This script needs root privileges to run")' >> /usr/bin/autoaspm
echo '    lspci_detected = subprocess.run(["which", "lspci"], stdout = subprocess.DEVNULL, stderr = subprocess.DEVNULL)' >> /usr/bin/autoaspm
echo '    if lspci_detected.returncode > 0:' >> /usr/bin/autoaspm
echo '        raise Exception("lspci not detected. Please install pciutils")' >> /usr/bin/autoaspm
echo '    lspci_detected = subprocess.run(["which", "setpci"], stdout = subprocess.DEVNULL, stderr = subprocess.DEVNULL)' >> /usr/bin/autoaspm
echo '    if lspci_detected.returncode > 0:' >> /usr/bin/autoaspm
echo '        raise Exception("setpci not detected. Please install pciutils")' >> /usr/bin/autoaspm
echo '' >> /usr/bin/autoaspm
echo '' >> /usr/bin/autoaspm
echo 'def get_device_name(addr):' >> /usr/bin/autoaspm
echo '    p = subprocess.Popen([' >> /usr/bin/autoaspm
echo '        "lspci",' >> /usr/bin/autoaspm
echo '        "-s",' >> /usr/bin/autoaspm
echo '        addr,' >> /usr/bin/autoaspm
echo '    ], stdout=subprocess.PIPE, stderr=subprocess.PIPE)' >> /usr/bin/autoaspm
echo '    return p.communicate()[0].splitlines()[0].decode()' >> /usr/bin/autoaspm
echo '' >> /usr/bin/autoaspm
echo 'def read_all_bytes(device):' >> /usr/bin/autoaspm
echo '    all_bytes = bytearray()' >> /usr/bin/autoaspm
echo '    device_name = get_device_name(device)' >> /usr/bin/autoaspm
echo '    p = subprocess.Popen([' >> /usr/bin/autoaspm
echo '        "lspci",' >> /usr/bin/autoaspm
echo '        "-s",' >> /usr/bin/autoaspm
echo '        device,' >> /usr/bin/autoaspm
echo '        "-xxx"' >> /usr/bin/autoaspm
echo '    ], stdout= subprocess.PIPE, stderr=subprocess.PIPE)' >> /usr/bin/autoaspm
echo '    ret = p.communicate()' >> /usr/bin/autoaspm
echo '    ret = ret[0].decode()' >> /usr/bin/autoaspm
echo '    for line in ret.splitlines():' >> /usr/bin/autoaspm
echo '        if not device_name in line and ": " in line:' >> /usr/bin/autoaspm
echo '            all_bytes.extend(bytearray.fromhex(line.split(": ")[1]))' >> /usr/bin/autoaspm
echo '    if len(all_bytes) < 256:' >> /usr/bin/autoaspm
echo '        exit()' >> /usr/bin/autoaspm
echo '    return all_bytes' >> /usr/bin/autoaspm
echo '' >> /usr/bin/autoaspm
echo 'def find_byte_to_patch(bytes, pos):' >> /usr/bin/autoaspm
echo '    pos = bytes[pos]' >> /usr/bin/autoaspm
echo '    if bytes[pos] != 0x10:' >> /usr/bin/autoaspm
echo '        pos += 0x1' >> /usr/bin/autoaspm
echo '        return find_byte_to_patch(bytes, pos)' >> /usr/bin/autoaspm
echo '    else:' >> /usr/bin/autoaspm
echo '        pos += 0x10' >> /usr/bin/autoaspm
echo '        return pos' >> /usr/bin/autoaspm
echo '' >> /usr/bin/autoaspm
echo 'def patch_byte(device, position, value):' >> /usr/bin/autoaspm
echo '    subprocess.Popen([' >> /usr/bin/autoaspm
echo '        "setpci",' >> /usr/bin/autoaspm
echo '        "-s",' >> /usr/bin/autoaspm
echo '        device,' >> /usr/bin/autoaspm
echo '        f"{hex(position)}.B={hex(value)}"' >> /usr/bin/autoaspm
echo '    ]).communicate()' >> /usr/bin/autoaspm
echo '' >> /usr/bin/autoaspm
echo 'def patch_device(addr, aspm_value):' >> /usr/bin/autoaspm
echo '    endpoint_bytes = read_all_bytes(addr)' >> /usr/bin/autoaspm
echo '    byte_position_to_patch = find_byte_to_patch(endpoint_bytes, 0x34)' >> /usr/bin/autoaspm
echo '    if int(endpoint_bytes[byte_position_to_patch]) & 0b11 != aspm_value.value:' >> /usr/bin/autoaspm
echo '        patched_byte = int(endpoint_bytes[byte_position_to_patch])' >> /usr/bin/autoaspm
echo '        patched_byte = patched_byte >> 2' >> /usr/bin/autoaspm
echo '        patched_byte = patched_byte << 2' >> /usr/bin/autoaspm
echo '        patched_byte = patched_byte | aspm_value.value' >> /usr/bin/autoaspm
echo '' >> /usr/bin/autoaspm
echo '        patch_byte(addr, byte_position_to_patch, patched_byte)' >> /usr/bin/autoaspm
echo '        print(f"{addr}: Enabled ASPM {aspm_value.name}")' >> /usr/bin/autoaspm
echo '    else:' >> /usr/bin/autoaspm
echo '        print(f"{addr}: Already has ASPM {aspm_value.name} enabled")' >> /usr/bin/autoaspm
echo '' >> /usr/bin/autoaspm
echo '' >> /usr/bin/autoaspm
echo 'def list_supported_devices():' >> /usr/bin/autoaspm
echo '    pcie_addr_regex = r"([0-9a-f]{2}:[0-9a-f]{2}\.[0-9a-f])"' >> /usr/bin/autoaspm
echo '    lspci = subprocess.run("lspci -vv", shell=True, capture_output=True).stdout' >> /usr/bin/autoaspm
echo '    lspci_arr = re.split(pcie_addr_regex, str(lspci))[1:]' >> /usr/bin/autoaspm
echo '    lspci_arr = [ x+y for x,y in zip(lspci_arr[0::2], lspci_arr[1::2]) ]' >> /usr/bin/autoaspm
echo '' >> /usr/bin/autoaspm
echo '    aspm_devices = {}' >> /usr/bin/autoaspm
echo '    for dev in lspci_arr:' >> /usr/bin/autoaspm
echo '        device_addr = re.findall(pcie_addr_regex, dev)[0]' >> /usr/bin/autoaspm
echo '        if "ASPM" not in dev or "ASPM not supported" in dev:' >> /usr/bin/autoaspm
echo '            continue' >> /usr/bin/autoaspm
echo '        aspm_support = re.findall(r"ASPM (L[L0-1s ]*),", dev)' >> /usr/bin/autoaspm
echo '        if aspm_support:' >> /usr/bin/autoaspm
echo '            aspm_devices.update({device_addr: ASPM[aspm_support[0].replace(" ", "")]})' >> /usr/bin/autoaspm
echo '    return aspm_devices' >> /usr/bin/autoaspm
echo '' >> /usr/bin/autoaspm
echo '' >> /usr/bin/autoaspm
echo 'def main():' >> /usr/bin/autoaspm
echo '    run_prerequisites()' >> /usr/bin/autoaspm
echo '    for device, aspm_mode in list_supported_devices().items():' >> /usr/bin/autoaspm
echo '        patch_device(device, aspm_mode)' >> /usr/bin/autoaspm
echo '' >> /usr/bin/autoaspm
echo 'if __name__ == "__main__":' >> /usr/bin/autoaspm
echo '    main()' >> /usr/bin/autoaspm
echo
chmod +x /usr/bin/autoaspm
(crontab -l 2>/dev/null; echo "@reboot (sleep 60 && /usr/bin/autoaspm)") | crontab -

# setup backup-host-to
echo
echo '#!/bin/bash' > /usr/bin/backup-host-to
echo '' >> /usr/bin/backup-host-to
echo '! /usr/sbin/pvesm status --storage "$1" >/dev/null 2>&1 &&' >> /usr/bin/backup-host-to
echo '  echo "Storage ($1) not found, skipping backup" &&' >> /usr/bin/backup-host-to
echo '  exit 1' >> /usr/bin/backup-host-to
echo '' >> /usr/bin/backup-host-to
echo 'PBS_DATASTORE=$(sed -n "/pbs: $1/,/^$/p" /etc/pve/storage.cfg | sed -n "s/\s.*datastore //p")' >> /usr/bin/backup-host-to
echo 'test -z "$PBS_DATASTORE" &&' >> /usr/bin/backup-host-to
echo '  echo "Storage ($1) configuration PBS_DATASTORE, skipping backup" &&' >> /usr/bin/backup-host-to
echo '  exit 1' >> /usr/bin/backup-host-to
echo '' >> /usr/bin/backup-host-to
echo 'PBS_NAMESPACE=$(sed -n "/pbs: $1/,/^$/p" /etc/pve/storage.cfg | sed -n "s/\s.*namespace //p")' >> /usr/bin/backup-host-to
echo 'test -z "$PBS_DATASTORE" &&' >> /usr/bin/backup-host-to
echo '  echo "Storage ($1) configuration PBS_NAMESPACE, skipping backup" &&' >> /usr/bin/backup-host-to
echo '  exit 1' >> /usr/bin/backup-host-to
echo '' >> /usr/bin/backup-host-to
echo 'PBS_SERVER=$(sed -n "/pbs: $1/,/^$/p" /etc/pve/storage.cfg | sed -n "s/\s.*server //p")' >> /usr/bin/backup-host-to
echo 'test -z "$PBS_DATASTORE" &&' >> /usr/bin/backup-host-to
echo '  echo "Storage ($1) configuration PBS_SERVER, skipping backup" &&' >> /usr/bin/backup-host-to
echo '  exit 1' >> /usr/bin/backup-host-to
echo '' >> /usr/bin/backup-host-to
echo 'PBS_USERNAME=$(sed -n "/pbs: $1/,/^$/p" /etc/pve/storage.cfg | sed -n "s/\s.*username //p")' >> /usr/bin/backup-host-to
echo 'test -z "$PBS_DATASTORE" &&' >> /usr/bin/backup-host-to
echo '  echo "Storage ($1) configuration PBS_USERNAME, skipping backup" &&' >> /usr/bin/backup-host-to
echo '  exit 1' >> /usr/bin/backup-host-to
echo '' >> /usr/bin/backup-host-to
echo 'PBS_FINGERPRINT=$(sed -n "/pbs: $1/,/^$/p" /etc/pve/storage.cfg | sed -n "s/\s.*fingerprint //p")' >> /usr/bin/backup-host-to
echo 'test -z "$PBS_DATASTORE" &&' >> /usr/bin/backup-host-to
echo '  echo "Storage ($1) configuration PBS_FINGERPRINT, skipping backup" &&' >> /usr/bin/backup-host-to
echo '  exit 1' >> /usr/bin/backup-host-to
echo '' >> /usr/bin/backup-host-to
echo 'PBS_PASSWORD=$(cat "/etc/pve/priv/storage/$1.pw")' >> /usr/bin/backup-host-to
echo 'test -z "$PBS_DATASTORE" &&' >> /usr/bin/backup-host-to
echo '  echo "Storage ($1) configuration PBS_PASSWORD, skipping backup" &&' >> /usr/bin/backup-host-to
echo '  exit 1' >> /usr/bin/backup-host-to
echo '' >> /usr/bin/backup-host-to
echo 'PBS_REPOSITORY="$PBS_USERNAME@$PBS_SERVER:$PBS_DATASTORE"' >> /usr/bin/backup-host-to
echo 'test -z "$PBS_DATASTORE" &&' >> /usr/bin/backup-host-to
echo '  echo "Storage ($1) configuration PBS_REPOSITORY, skipping backup" &&' >> /usr/bin/backup-host-to
echo '  exit 1' >> /usr/bin/backup-host-to
echo '' >> /usr/bin/backup-host-to
echo 'export PBS_FINGERPRINT PBS_PASSWORD PBS_REPOSITORY' >> /usr/bin/backup-host-to
echo '/usr/bin/proxmox-backup-client backup root.pxar:/ --ns "$PBS_NAMESPACE"' >> /usr/bin/backup-host-to
echo
chmod +x /usr/bin/backup-host-to

# add dependencies
apt install -y btop fastfetch ufw
reboot

# setup network
echo
echo '# network interface settings; autogenerated' > /etc/network/interfaces
echo '# Please do NOT modify this file directly, unless you know what' >> /etc/network/interfaces
echo "# you're doing." >> /etc/network/interfaces
echo '#' >> /etc/network/interfaces
echo '# If you want to manage parts of the network configuration manually,' >> /etc/network/interfaces
echo "# please utilize the 'source' or 'source-directory' directives to do" >> /etc/network/interfaces
echo '# so.' >> /etc/network/interfaces
echo '# PVE will preserve these directives, but will NOT read its network' >> /etc/network/interfaces
echo '# configuration from sourced files, so do not attempt to move any of' >> /etc/network/interfaces
echo '# the PVE managed interfaces into external files!' >> /etc/network/interfaces
echo '' >> /etc/network/interfaces
echo 'source /etc/network/interfaces.d/*' >> /etc/network/interfaces
echo '' >> /etc/network/interfaces
echo 'auto lo' >> /etc/network/interfaces
echo 'iface lo inet loopback' >> /etc/network/interfaces
echo '' >> /etc/network/interfaces
echo 'auto enp3s0' >> /etc/network/interfaces
echo 'iface enp3s0 inet manual' >> /etc/network/interfaces
echo '	dns-nameservers 192.168.0.1' >> /etc/network/interfaces
echo '' >> /etc/network/interfaces
echo 'iface wlo1 inet manual' >> /etc/network/interfaces
echo '' >> /etc/network/interfaces
echo 'auto vmbr0' >> /etc/network/interfaces
echo 'iface vmbr0 inet static' >> /etc/network/interfaces
echo '	address 192.168.0.31/24' >> /etc/network/interfaces
echo '	gateway 192.168.0.1' >> /etc/network/interfaces
echo '	bridge-ports enp3s0' >> /etc/network/interfaces
echo '	bridge-stp off' >> /etc/network/interfaces
echo '	bridge-fd 0' >> /etc/network/interfaces
echo
systemctl daemon-reload
systemctl restart networking

# setup firewall
apt install -y ufw
ufw default allow outgoing
ufw default deny incoming
# SSH
ufw allow from 10.0.0.0/8 to any port 22 proto tcp
ufw allow from 172.16.0.0/12 to any port 22 proto tcp
ufw allow from 192.168.0.0/16 to any port 22 proto tcp
# Proxmox
ufw allow from 10.0.0.0/8 to any port 8006 proto tcp
ufw allow from 172.16.0.0/12 to any port 8006 proto tcp
ufw allow from 192.168.0.0/16 to any port 8006 proto tcp
ufw enable

```
