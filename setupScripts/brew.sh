#!/bin/bash

if command -v brew &>/dev/null; then
  echo "Homebrew already installed."
else
  echo "Homebrew not found - installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Apply to current shell
fi

#NOTE: Just for container
if [ "$(uname)" == "Linux" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

brew bundle
