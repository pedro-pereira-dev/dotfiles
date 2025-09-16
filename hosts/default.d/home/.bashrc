#!/bin/bash
# returns early if is a non-interactive shell
[[ $- != *i* ]] && return
# resizes window and appends commands to history
shopt -s checkwinsize histappend

# WIP

command -v sway >/dev/null && [[ -z "${WAYLAND_DISPLAY}" && "${XDG_VTNR}" -eq 1 ]] && dbus-run-session sway || true

export FZF_DEFAULT_OPTS="--bind 'tab:down,shift-tab:up' --cycle --reverse"
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'

export PATH="$HOME/.local/bin:$PATH"

command -v doas >/dev/null && complete -cf doas || true
command -v fnm >/dev/null && eval "$(fnm env --use-on-cd --shell bash)" || true
command -v starship >/dev/null && eval "$(starship init bash)" || true
command -v zoxide >/dev/null && eval "$(zoxide init --cmd cd bash)" || true

alias ls='eza --all --long --icons --sort=type'
alias tree='eza --all --tree --icons --sort=type'
alias vi='nvim-reloadable'

alias poweroff='doas poweroff'
alias reboot='doas reboot'
alias shutdown='doas shutdown -h now'

alias ~='cd ~'
alias ..='cd ..'
alias ...='cd ../..'
