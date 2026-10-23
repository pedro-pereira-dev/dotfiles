#!/usr/bin/env bash
# shellcheck disable=SC2154

is_darwin() {
  grep -q darwinModules "$DOTS_ROOT/hosts/$1/default.nix"
}
