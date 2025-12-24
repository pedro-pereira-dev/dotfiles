#!/bin/sh
# shellcheck disable=SC2086
set -eou pipefail

DOMAINS=$(echo "$DOMAINS" | sed 's/^/-d /' | sed 's/,/ -d /g')
SPACESHIP_API_KEY=$(cat "$ACME_SPACESHIP_API_KEY_FILE" | tr -d '\n')
SPACESHIP_API_SECRET=$(cat "$ACME_SPACESHIP_API_SECRET_FILE" | tr -d '\n')
export DOMAINS SPACESHIP_API_KEY SPACESHIP_API_SECRET

/entry.sh --issue --dns dns_spaceship --server letsencrypt $DOMAINS
/entry.sh --deploy --deploy-hook haproxy $DOMAINS
