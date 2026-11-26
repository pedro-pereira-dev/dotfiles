#!/usr/bin/env bash
# shellcheck disable=SC2154

is_nix_darwin() {
  grep -q darwinConfigurations "$DOTS_ROOT/modules/hosts/$1.nix"
}
