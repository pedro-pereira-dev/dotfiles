#!/bin/bash

# exits if the shell is not interactive
[[ $- != *i* ]] && return

# loads hostname specific configurations
case $(uname -n) in
gentoo-laptop-msi-es)
  # adds local bin directory to PATH
  [[ ":${PATH}:" != *":${HOME}/.local/bin:"* && -d "${HOME}/.local/bin" ]] && export PATH="${HOME}/.local/bin:${PATH}"
  # starts shell customizations
  export GPG_TTY=$(tty)
  [[ ! -z $(command -v keychain) ]] && eval $(keychain --eval --quiet) # secrets
  [[ ! -z $(command -v starship) ]] && eval $(starship init bash)      # prompt
  [[ ! -z $(command -v zoxide) ]] && eval $(zoxide init --cmd cd bash) # directory navigation
  # sets up aliases
  alias doas='doas '                              # alias for doas
  alias reboot='doas reboot'                      # alias for reboot
  alias shutdown='doas shutdown -h now'           # alias for shut down now
  alias ls='eza --long --icons --all --sort=type' # alias for ls with eza
  alias vi='nvim'                                 # alias for neovim
  alias ~='cd ~'
  alias ..='cd ..'
  alias ...='cd ../..'
  alias ....='cd ../../..'
  ;;
esac
