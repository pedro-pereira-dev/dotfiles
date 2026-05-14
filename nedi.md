# `nedi`

## Details

- Site: Personal
- OS: Debian 13 / Proxmox 9
- IPv4: `192.168.0.32`

```
root@nedi:~# lsblk -o NAME,FSTYPE,UUID,SIZE,FSAVAIL,MOUNTPOINTS
NAME                         FSTYPE      UUID                                     SIZE FSAVAIL MOUNTPOINTS
sda                                                                             223.6G
├─sda1                       vfat        DFE9-64DC                                 63M   57.6M /boot/efi
└─sda2                       LVM2_member 16J7Dc-UyEk-5vVZ-3t8I-32mj-gco6-VuzYxP 223.5G
  ├─vg-swap                  swap        c2cbfde3-3d8e-43a6-b3cb-4f632d566a87       1G         [SWAP]
  ├─vg-root                  ext4        0f1bfbdf-665b-4f74-9b40-2d258c5ee764      16G   10.4G /
  ├─vg-data_tmeta                                                                 104M
  │ └─vg-data-tpool                                                             206.3G
  │   ├─vg-data                                                                 206.3G
  └─vg-data_tdata                                                               206.3G
    └─vg-data-tpool                                                             206.3G
      ├─vg-data                                                                 206.3G
sdb                                                                             223.6G
└─sdb1                       ext4        39a0ece3-e591-4076-b9fa-18623e9441ff   223.6G  207.8G /mnt/disks/fast-01
sdc                                                                             931.5G
└─sdc1                       ext4        3d2a00d4-0650-4a0c-af1c-30e814922cda   931.5G  869.2G /mnt/disks/slow-01
sdd                                                                             931.5G
└─sdd1                       ext4        ce94c2e2-b0e7-40c0-89a0-1846bc567155   931.5G  869.2G /mnt/disks/parity-01
```

Ports opened:

```
root@nedi:~# ufw status verbose
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
echo 'UUID=DFE9-64DC          /boot/efi       vfat defaults,noatime,nodev,noexec,nosuid,umask=0077 0 2' > /etc/fstab
echo '/dev/mapper/vg-root     /               ext4 defaults,errors=remount-ro 0 1' >> /etc/fstab
echo '/dev/mapper/vg-swap     none            swap sw 0 0' >> /etc/fstab
echo '' >> /etc/fstab
echo 'UUID=39a0ece3-e591-4076-b9fa-18623e9441ff     /mnt/disks/fast-01      ext4 defaults 0 0' >> /etc/fstab
echo 'UUID=3d2a00d4-0650-4a0c-af1c-30e814922cda     /mnt/disks/slow-01      ext4 defaults 0 0' >> /etc/fstab
echo 'UUID=ce94c2e2-b0e7-40c0-89a0-1846bc567155     /mnt/disks/parity-01    ext4 defaults 0 0' >> /etc/fstab

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
(crontab -l 2>/dev/null; echo "0 */3 * * * (sleep 60 && /usr/bin/backup-host-to nedi-pbs-local)") | crontab -

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
echo '	address 192.168.0.32/24' >> /etc/network/interfaces
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
