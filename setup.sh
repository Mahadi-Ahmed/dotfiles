#!/bin/bash

printf "Welcome lab Member 003 Suupar Hacker\nSetting up environment IBN5100...\nEl Psy Congroo\n"

echo "Brewing..."
source ./setupScripts/brew.sh

echo "Stowing..."
source ./setupScripts/stow.sh

# "Creating Neovim undo directory"
mkdir -p ~/.undodir
chmod 700 ~/.undodir

echo "Installing tpm - tmux plugin manager"
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

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

if ! command -v atuin &>/dev/null; then
  echo "Installing atuin"
  curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
else
  echo "atuin already installed, skipping..."
fi

if ! command -v rustup &>/dev/null; then
  echo "Installing rustup (Rust toolchain)"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
else
  echo "rustup already installed, skipping..."
fi

echo "Setting up asdf plugins and languages"
# Add Node.js plugin
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git 2>/dev/null || echo "nodejs plugin already added"

# Add Ruby plugin
asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git 2>/dev/null || echo "ruby plugin already added"

# Add Python plugin
asdf plugin add python https://github.com/asdf-community/asdf-python.git 2>/dev/null || echo "python plugin already added"

# Install Node.js LTS
echo "Installing Node.js LTS..."
asdf install nodejs lts

# Install Ruby latest
echo "Installing Ruby latest..."
asdf install ruby latest

# Install Python latest
echo "Installing Python latest..."
asdf install python latest

# Set global versions in $HOME/.tool-versions
asdf set -u nodejs lts
asdf set -u ruby latest
asdf set -u python latest

echo "asdf setup complete!"
echo "Node.js version: $(asdf current nodejs)"
echo "Ruby version: $(asdf current ruby)"
echo "Python version: $(asdf current python)"

# Install pipx for Python CLI tools
echo "Installing pipx..."
pip install pipx
pipx ensurepath

if [ "$(uname)" = "Darwin" ]; then
  echo "Setting up osx settings"
  source ./setupScripts/osx.sh
fi
