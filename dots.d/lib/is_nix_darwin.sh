#!/usr/bin/env bash
# shellcheck disable=SC2154

is_nix_darwin() {
  grep -q darwinModules "$DOTS_ROOT/hosts/$1.d/$1.nix"
}
