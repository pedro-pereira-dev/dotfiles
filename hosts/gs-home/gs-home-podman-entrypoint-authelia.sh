#!/bin/sh
set -eou pipefail

AUTHELIA_IDENTITY_PROVIDERS_OIDC_CLIENTS_VAULTWARDEN_SECRET=$(cat "$AUTHELIA_IDENTITY_PROVIDERS_OIDC_CLIENTS_VAULTWARDEN_SECRET_FILE" | tr -d "\n")
AUTHELIA_IDENTITY_PROVIDERS_OIDC_JWKS_KEY=$(cat "$AUTHELIA_IDENTITY_PROVIDERS_OIDC_JWKS_KEY_FILE" | sed '1!s/^/          /')
export AUTHELIA_IDENTITY_PROVIDERS_OIDC_CLIENTS_VAULTWARDEN_SECRET AUTHELIA_IDENTITY_PROVIDERS_OIDC_JWKS_KEY

while IFS= read -r _line; do eval "echo \"$_line\""; done </authelia.yml >/configuration.yml
until nc -w 1 host.containers.internal 6379 </dev/null; do sleep 1; done
exec /app/entrypoint.sh
