#!/bin/sh
set -eou pipefail

_check_interval=5    # hours
_renewal_interval=60 # hours
_renewal_timestamp=/data/timestamp

apk add --no-cache acme.sh || exit 1

while true; do
  _now=$(date +%s)

  [ ! -f $_renewal_timestamp ] &&
    echo "$((_now - _renewal_interval))" >$_renewal_timestamp
  _previous=$(cat $_renewal_timestamp)
  echo "previousss $_previous"

  _elapsed=$((_now - _previous))
  [ $_elapsed -ge $_renewal_interval ] &&
    echo 'running command' &&
    echo "$_now" >$_renewal_timestamp

  sleep $_check_interval
done
