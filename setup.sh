#!/bin/bash

printf "Welcome lab Member 003 Suupar Hacker\nSetting up environment IBN5100...\nEl Psy Congroo\n"

echo "Installing p10k"
source ./setupScripts/p10kSetup.sh

echo "Brewing..."
source ./setupScripts/brew.sh

echo "Stowing..."
source ./setupScripts/stow.sh

echo "Installing tpm - tmux plugin manager"
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

#TODO: Install volta - (https://docs.volta.sh/advanced/installers#skipping-volta-setup)

if [ "$(uname)" == "Darwin" ]; then
	if command -v xcode-select &>/dev/null; then
		echo "Xcode Command Line Tools already installed."
	else
		echo "Xcode Command Line Tools not found - installing..."
		xcode-select --install
		sudo xcodebuild -license accept
	fi
fi

#TODO: Remove later
#NOTE: Just for the container
if [ "$(uname)" == "Linux" ]; then
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

exit 0
