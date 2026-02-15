#!/bin/sh
set -eou pipefail

USER_AUTHELIA_PASSWORD=$(cat "$USER_AUTHELIA_PASSWORD_FILE" | tr -d "\n")
export USER_AUTHELIA_PASSWORD

while IFS= read -r _line; do eval "echo \"$_line\""; done </valkey.conf >/configuration.conf
exec valkey-server /configuration.conf
