#!/usr/bin/env bash
set -euo pipefail

if ! command -v git >/dev/null; then
  brew install git
fi
