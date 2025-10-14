#!/bin/sh
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/gentoo-server.d/layer-compose.yaml" "$_HOME/.podman/compose.yaml"
# run_as_root stow "$_HOME/$_DOTS_DIR/gentoo-server.d/layer-podman-compose-service.sh" '/etc/init.d/podman-compose'
