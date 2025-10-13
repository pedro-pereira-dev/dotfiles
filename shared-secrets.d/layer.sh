#!/bin/sh
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-secrets.d/layer-bin-secrets-bootstrap.sh" "$_HOME/.local/bin/secrets-bootstrap"
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-secrets.d/layer-bin-secrets-create.sh" "$_HOME/.local/bin/secrets-create"
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-secrets.d/layer-bin-secrets-import.sh" "$_HOME/.local/bin/secrets-import"
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-secrets.d/layer-bin-secrets-remove.sh" "$_HOME/.local/bin/secrets-remove"
run_as_user "$_USER" stow "$_HOME/$_DOTS_DIR/shared-secrets.d/layer-bin-secrets-set.sh" "$_HOME/.local/bin/secrets-set"
