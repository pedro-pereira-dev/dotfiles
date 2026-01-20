#!/bin/sh
# shellcheck disable=SC2086
set -eou pipefail

run_acme() {
  podman run \
    --name acme --network podman_public --replace --rm \
    -v /mnt/data/managed/acme/account:/acme.sh \
    -v /mnt/data/managed/acme/certs:/etc/haproxy \
    docker.io/neilpang/acme.sh:latest "$@"
}

HAPROXY_DOMAINS=$(grep -oP 'use_backend .* -i \K\S+' /etc/podman/haproxy.cfg | sed 's/^/-d /' | tr '\n' ' ')
run_acme --issue --server letsencrypt --standalone $HAPROXY_DOMAINS
run_acme --deploy --deploy-hook haproxy $HAPROXY_DOMAINS
podman kill -s HUP haproxy
