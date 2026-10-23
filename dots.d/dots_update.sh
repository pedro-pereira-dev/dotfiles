#!/usr/bin/env bash

dots_update() {
  dots_pull >/dev/null
  exec "$DOTS_ROOT/dots" setup "$@"
}
