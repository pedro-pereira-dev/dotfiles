#!/bin/sh
# shellcheck disable=SC2046,SC2086
set -eou pipefail

_args='' && [ "$#" -ge 1 ] && _args=$1

podman-compose -f /home/chuck/.config/podman/compose.yaml down
kill $(pgrep 'aardvark|catatonit' | xargs)
podman-compose -f /home/chuck/.config/podman/compose.yaml up $_args

exit 0
