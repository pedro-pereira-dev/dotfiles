#!/bin/sh
# run_as_root stow "$_HOME/$_DOTS_DIR/gentoo-podman-server.d/layer-podman-compose-service.sh" '/etc/init.d/podman-compose'
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/gentoo-podman-server.d/layer-compose.yaml" "$_HOME/.podman/compose.yaml"
