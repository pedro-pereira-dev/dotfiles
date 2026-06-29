#!/bin/bash
mkdir -p /tmp/nebula-sync
curl -Lfs "$(
  curl -s https://api.github.com/repos/lovelaze/nebula-sync/releases/latest |
    grep 'browser_download_url.*linux_amd64.tar.gz' | cut -d '"' -f 4
)" -o /tmp/nebula-sync/nebula-sync.tar.gz
tar -xf /tmp/nebula-sync/nebula-sync.tar.gz -C /tmp/nebula-sync
mv /tmp/nebula-sync/nebula-sync /usr/bin/
chmod +x /usr/bin/nebula-sync
rm -fr /tmp/nebula-sync

#!/bin/bash

# updates debian
apt update
apt full-upgrade -y
apt autoremove -y

# updates nebula
mkdir -p /tmp/nebula-sync
curl -Lfs "$(
  curl -s https://api.github.com/repos/lovelaze/nebula-sync/releases/latest |
    grep 'browser_download_url.*linux_amd64.tar.gz' | cut -d '"' -f 4
)" -o /tmp/nebula-sync/nebula-sync.tar.gz
tar -xf /tmp/nebula-sync/nebula-sync.tar.gz -C /tmp/nebula-sync
mv /tmp/nebula-sync/nebula-sync /usr/bin/
chmod +x /usr/local/bin/nebula-sync
rm -fr /tmp/nebula-sync

# updates pihole
pihole -up
