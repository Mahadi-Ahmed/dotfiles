#!/bin/bash

if command -v brew &>/dev/null; then
  echo "Homebrew already installed."
else
  echo "Homebrew not found - installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ "$(uname)" == "Darwin" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  #NOTE: Just for pi/container
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

brew bundle
