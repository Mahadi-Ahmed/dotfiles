#!/bin/bash

if [ -f ~/.zshrc ]; then
  echo "Found a zshrc, backing it up"
  mv ~/.zshrc ~/.zshrc.bootstrap.backup
fi

stow -vt ~ nvim
stow -vt ~ aerospace
stow -vt ~ bat
stow -vt ~ kitty
stow -vt ~ starship
stow -vt ~ tmux
stow -vt ~ zshrc
