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

echo "Setting up mise languages"

# Install runtimes (mise auto-discovers from its built-in registry, no plugin step needed)
echo "Installing Node.js LTS..."
mise install node@lts

echo "Installing Ruby latest..."
mise install ruby@latest

echo "Installing Python latest..."
mise install python@latest

echo "Installing Go latest..."
mise install go@latest

# Set global versions in ~/.config/mise/config.toml
mise use -g node@lts
mise use -g ruby@latest
mise use -g python@latest
mise use -g go@latest

echo "mise setup complete!"
echo "Node.js version: $(mise current node)"
echo "Ruby version: $(mise current ruby)"
echo "Python version: $(mise current python)"
echo "Go version: $(mise current go)"

# Install pipx for Python CLI tools
echo "Installing pipx..."
pip install pipx
pipx ensurepath

if [ "$(uname)" = "Darwin" ]; then
  echo "Setting up osx settings"
  source ./setupScripts/osx.sh
fi
