#!/bin/bash
# shellcheck disable=SC2015 disable=SC2088 source=/dev/null
set -eou pipefail

_HOME="$(get_home "$@")"

# ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- ----- -----
# changes default shell to bash if not already
[ "$SHELL" != '/bin/bash' ] &&
  chsh -s /bin/bash && [ -d "$_HOME/.bashrc" ] && source "$_HOME/.bashrc"
