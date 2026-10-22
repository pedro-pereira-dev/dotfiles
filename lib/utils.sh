#!/usr/bin/env bash

is_darwin() { grep -q darwinModules "$DOTS_ROOT/hosts/$1/default.nix"; }
is_host_configured() { [[ -f $DOTS_ROOT/hosts/$1/default.nix ]] || { printf '%s - no configuration\n' "$1" >&2 && exit 1; }; }
