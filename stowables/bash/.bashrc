#!/bin/bash

# exits if the shell is not interactive
[[ $- != *i* ]] && return 0
# loads hostname specific configurations
case $(uname -n) in
  gl-dell | gl-red)
    # sets shell customizations
    [[ ! -z $(command -v starship) ]] && eval "$(starship init bash)"      # prompt
    [[ ! -z $(command -v zoxide) ]] && eval "$(zoxide init --cmd cd bash)" # directory navigation
    # sets up aliases
    alias ls='eza --long --icons --all --sort=type' # alias for ls with eza

    alias vi='myvim'                             # alias for neovim
    alias vv='myvim ~/.config/nvim/init.lua'     # alias for neovim init edition

    alias reboot='doas reboot'                      # alias for reboot
    alias shutdown='doas shutdown -h now'           # alias for shut down now
    alias doas='doas '                              # alias for doas
    alias ~='cd ~'
    alias ..='cd ..'
    alias ...='cd ../..'
    alias ....='cd ../../..'
  ;;
esac
