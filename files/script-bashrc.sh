#!/bin/bash
[[ $- != *i* ]] && return        # returns early if is non-interactive shell
shopt -s checkwinsize histappend # resizes window and appends commands to history

is_linux() { test "$(uname)" = Linux; }
is_macos() { test "$(uname)" = Darwin; }

[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH="$HOME/.local/bin:$PATH"
is_macos && [[ ":$PATH:" != *':/opt/homebrew/bin:'* ]] && export PATH="/opt/homebrew/bin:$PATH"

is_linux && command -v nft-trust-ip >/dev/null && [ -n "$SSH_CONNECTION" ] &&
  doas nft-trust-ip "$(echo "$SSH_CONNECTION" | cut -d' ' -f1)"

is_macos &&
  export BASH_SILENCE_DEPRECATION_WARNING=1 &&
  export HOMEBREW_NO_ENV_HINTS=1

# WIP
command -v sway >/dev/null && [[ -z "${WAYLAND_DISPLAY}" && "${XDG_VTNR}" -eq 1 ]] && dbus-run-session sway || true

export FZF_DEFAULT_OPTS="--bind 'tab:down,shift-tab:up' --cycle --reverse"
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'

command -v doas >/dev/null && complete -cf doas || true
command -v fnm >/dev/null && eval "$(fnm env --use-on-cd --shell bash)" || true
command -v starship >/dev/null && eval "$(starship init bash)" || true
command -v zoxide >/dev/null && eval "$(zoxide init --cmd cd bash)" || true

command -v eza >/dev/null && alias ls='eza --all --long --icons --sort=type'
command -v eza >/dev/null && alias tree='eza --all --tree --icons --sort=type'
alias vi='nvim-reloadable'

is_linux && alias poweroff='doas poweroff'
is_linux && alias reboot='doas reboot'
is_linux && alias shutdown='doas shutdown -h now'

alias ~='cd ~'
alias ..='cd ..'
alias ...='cd ../..'

alias p='doas -u podman'
alias pp='doas -u podman podman'
alias ppc='doas -u podman podman-compose -f /etc/podman/compose.yaml'
