# shellcheck source=/dev/null
[[ -f /etc/bash/bashrc ]] && source /etc/bash/bashrc

command -v doas >/dev/null && complete -cf doas
command -v fnm >/dev/null && eval "$(fnm env --use-on-cd --shell bash)"
command -v starship >/dev/null && eval "$(starship init bash)"
command -v zoxide >/dev/null && eval "$(zoxide init --cmd cd bash)"

alias ls='eza --all --long --icons --sort=type'
alias tree='eza --all --tree --icons --sort=type'
alias vi='nvim-reloadable'

alias reboot='doas reboot'
alias shutdown='doas shutdown -h now'

alias ~='cd ~'
alias ..='cd ..'
alias ...='cd ../..'
