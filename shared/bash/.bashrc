# shellcheck source=/dev/null
[[ -f /etc/bash/bashrc ]] && source /etc/bash/bashrc

[[ -n $(command -v fnm) ]] && eval "$(fnm env --use-on-cd --shell bash)"
[[ -n $(command -v starship) ]] && eval "$(starship init bash)"
[[ -n $(command -v zoxide) ]] && eval "$(zoxide init --cmd cd bash)"

alias code='tmux-sessionixidizer'
alias ls='eza --all --long --icons --sort=type'
alias tree='eza --all --tree --icons --sort=type'
alias vi='nvim-hot-reloadable'

alias ~='cd ~'
alias ..='cd ..'
alias ...='cd ../..'
