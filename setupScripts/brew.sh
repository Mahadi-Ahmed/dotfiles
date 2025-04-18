#!/bin/bash

install_brew() {
  if command -v brew &>/dev/null; then
    echo "Homebrew already installed."
  else
    echo "Homebrew not found - installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # NOTE: Needed for in the container, remove when using rc from dotfiles
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc
    # Apply to current shell
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
}

main() {
  install_brew
  brew bundle
}

main
