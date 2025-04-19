#!/bin/bash

if [ -f ~/.zshrc ]; then
  echo "Found a zshrc, backing it up"
  mv ~/.zshrc ~/.zshrc.backup
fi

stow -vt ~ aerospace
stow -vt ~ bat
stow -vt ~ kitty
stow -vt ~ alacritty
stow -vt ~ p10k
stow -vt ~ ssh
stow -vt ~ tmux
stow -vt ~ zshrc
