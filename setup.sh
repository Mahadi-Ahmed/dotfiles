#!/bin/bash

printf "Welcome lab Member 003 Suupar Hacker\nSetting up environment IBN5100...\nEl Psy Congroo\n"

echo "Installing p10k"
source ./setupScripts/p10kSetup.sh

echo "Brewing..."
source ./setupScripts/brew.sh

echo "Stowing..."
source ./setupScripts/stow.sh

#TODO Install tpm
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

if [ "$(uname)" == "Linux" ]; then
  echo "its a linux machine"
fi

exit 0
