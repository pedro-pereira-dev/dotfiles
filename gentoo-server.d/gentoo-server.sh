#!/bin/sh
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/gentoo-server.d/podman-confs/" "$_HOME/.podman/"
