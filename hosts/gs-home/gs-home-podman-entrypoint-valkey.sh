#!/bin/sh
set -eou pipefail

USER_AUTHELIA_PASSWORD=$(cat "$USER_AUTHELIA_PASSWORD_FILE" | tr -d "\n")
export USER_AUTHELIA_PASSWORD

apk add --no-cache gettext
envsubst </valkey.conf >/configuration.conf
exec valkey-server /configuration.conf
