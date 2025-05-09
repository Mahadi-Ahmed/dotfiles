#!/bin/bash

if [ -f ~/.zshrc ]; then
  echo "Found a zshrc, backing it up"
  mv ~/.zshrc ~/.zshrc.bootstrap.backup
fi

stow -vt ~ nvim
stow -vt ~ aerospace
stow -vt ~ bat
stow -vt ~ kitty
stow -vt ~ alacritty
stow -vt ~ p10k
stow -vt ~ tmux
stow -vt ~ zshrc
