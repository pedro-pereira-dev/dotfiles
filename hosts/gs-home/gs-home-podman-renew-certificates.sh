#!/bin/sh

# renews certificate or issues new one if it does not exist
podman run --replace --rm --name acme --network podman_public \
  -v /mnt/data/managed/acme/account:/acme.sh -v /mnt/data/managed/acme/certs:/etc/haproxy \
  docker.io/neilpang/acme.sh:latest --issue --server letsencrypt --standalone "$@" \
  $(grep -oP 'use_backend .* -i \K\S+' /etc/podman/haproxy.cfg | sed 's/^/-d /' | tr '\n' ' ') &&

  # deploys certificate
  podman run --replace --rm --name acme --network podman_public \
    -v /mnt/data/managed/acme/account:/acme.sh -v /mnt/data/managed/acme/certs:/etc/haproxy \
    docker.io/neilpang/acme.sh:latest --deploy --deploy-hook haproxy \
    $(find /mnt/data/managed/acme/account -type d -name '*_ecc' -exec basename {} \; | sed 's/_ecc//' | sed 's/^/-d /' | tr '\n' ' ') &&

  # reloads haproxy gracefully
  podman kill -s HUP haproxy
