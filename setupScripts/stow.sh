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
stow -vt ~ worktrunk
stow -vt ~ zshrc

# The private layer (per-project worktrunk hooks) lives in a separate repo:
# github.com/Mahadi-Ahmed/dotfiles-private. It is optional — worktrunk works
# fine without it, just without those hooks.
PRIVATE_DOTFILES=~/Code/mahadia/dotfiles-private

if [ -d "$PRIVATE_DOTFILES" ]; then
  (cd "$PRIVATE_DOTFILES" && ./stow.sh)
else
  echo "⚠️  No dotfiles-private at $PRIVATE_DOTFILES"
  echo "    worktrunk will work, but without the per-project hooks (deps, .env, notes)."
  echo "    Clone it for the full config: git clone git@github.com:Mahadi-Ahmed/dotfiles-private.git $PRIVATE_DOTFILES"
fi
