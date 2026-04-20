#!/bin/sh
curl -Lfs "$(
  curl -s https://api.github.com/repos/rathole-org/rathole/releases/latest |
    jq -r --arg ARCH "$(uname -m)" --arg OS "$(uname -s | tr '[:upper:]' '[:lower:]')" \
      '.assets[] | select(.name | contains($ARCH) and contains($OS)) | .browser_download_url'
)" -o /tmp/rathole.zip
unzip -o /tmp/rathole.zip -d /usr/bin/ >/dev/null
chmod +x /usr/bin/rathole
rm -fr /tmp/rathole.zip
