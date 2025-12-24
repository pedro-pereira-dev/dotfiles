#!/bin/bash

# updates homebrew bundles
if [ -f "$HOME/Brewfile" ]; then

  echo "Removing untracked homebrew bundles..."
  (cd $HOME && brew bundle --force cleanup)

  echo "Installing / upgrading homebrew bundles..."
  (cd $HOME && brew bundle)
  brew update && brew upgrade

  echo "Removing old bundles..."
  brew autoremove

  echo "Cleaning up homebrew..."
  brew cleanup -s && rm -rf "$(brew --cache)"
fi
