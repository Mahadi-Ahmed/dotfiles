#!/bin/bash

printf "Welcome lab Member 003 Suupar Hacker\nSetting up environment IBN5100...\nEl Psy Congroo\n"

echo "Brewing..."
source ./setupScripts/brew.sh

echo "Stowing..."
source ./setupScripts/stow.sh

echo "Installing tpm - tmux plugin manager"
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

echo "Installing volta"
curl https://get.volta.sh | bash -s -- --skip-setup

#TODO: Setup osx settings (https://github.com/mathiasbynens/dotfiles/blob/main/.macos)


if [ "$(uname)" = "Darwin" ]; then
	if command -v xcode-select &>/dev/null; then
		echo "Xcode Command Line Tools already installed."
	else
		echo "Xcode Command Line Tools not found - installing..."
		xcode-select --install
		sudo xcodebuild -license accept
	fi
fi

#NOTE: Just for pi
if [ "$(uname)" = "Linux" ]; then

  echo "Installing Zoxide manually"
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

  echo "It's a Linux machine, installing eza manually..."
  
  wget -c https://github.com/eza-community/eza/releases/latest/download/eza_aarch64-unknown-linux-gnu.tar.gz -O - | tar xz

  sudo chmod +x eza
  sudo chown root:root eza
  sudo mv eza /usr/local/bin/eza
  
  # Check installation
  if command -v eza &>/dev/null; then
    echo "eza installed successfully!"
    eza --version
  else
    echo "eza installation failed."
  fi
fi

echo "Installing atuin"
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

echo "install node via volta"
volta install node@lts
