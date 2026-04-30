#!/bin/bash

printf "Welcome lab Member 003 Suupar Hacker\nSetting up Pi environment IBN5100...\nEl Psy Congroo\n"

# --- apt packages ---
echo "Installing apt packages..."
sudo apt update && sudo apt install -y \
  zsh tmux neovim git curl wget build-essential stow bat \
  fd-find ripgrep fzf tree unzip

# --- starship ---
if ! command -v starship &>/dev/null; then
  echo "Installing starship..."
  curl -sS https://starship.rs/install.sh | sh
else
  echo "starship already installed, skipping..."
fi

# --- atuin ---
if ! command -v atuin &>/dev/null; then
  echo "Installing atuin..."
  curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
else
  echo "atuin already installed, skipping..."
fi

# --- zoxide ---
if ! command -v zoxide &>/dev/null; then
  echo "Installing zoxide..."
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
else
  echo "zoxide already installed, skipping..."
fi

# --- eza ---
if ! command -v eza &>/dev/null; then
  echo "Installing eza..."
  wget -c https://github.com/eza-community/eza/releases/latest/download/eza_aarch64-unknown-linux-gnu.tar.gz -O - | tar xz
  sudo chmod +x eza
  sudo chown root:root eza
  sudo mv eza /usr/local/bin/eza
else
  echo "eza already installed, skipping..."
fi

# --- zsh plugins ---
ZSH_PLUGIN_DIR="${HOME}/.config/zsh/plugins"
mkdir -p "$ZSH_PLUGIN_DIR"

if [ ! -d "$ZSH_PLUGIN_DIR/zsh-autosuggestions" ]; then
  echo "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGIN_DIR/zsh-autosuggestions"
else
  echo "zsh-autosuggestions already installed, skipping..."
fi

if [ ! -d "$ZSH_PLUGIN_DIR/zsh-fast-syntax-highlighting" ]; then
  echo "Installing zsh-fast-syntax-highlighting..."
  git clone https://github.com/zdharma-continuum/fast-syntax-highlighting "$ZSH_PLUGIN_DIR/zsh-fast-syntax-highlighting"
else
  echo "zsh-fast-syntax-highlighting already installed, skipping..."
fi

# --- stow ---
echo "Stowing..."
source ./setupScripts/stow-pi.sh

# --- neovim undo directory ---
mkdir -p ~/.undodir
chmod 700 ~/.undodir

# --- tpm (tmux plugin manager) ---
if [ ! -d ~/.config/tmux/plugins/tpm ]; then
  echo "Installing tpm - tmux plugin manager..."
  git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
else
  echo "tpm already installed, skipping..."
fi

# --- change default shell ---
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "Changing default shell to zsh..."
  chsh -s "$(which zsh)"
else
  echo "zsh is already the default shell, skipping..."
fi

echo ""
echo "Setup complete!"
echo "Log out and back in for zsh to take effect."
echo "Then run 'nvim' and execute ':Lazy sync' to install plugins."
echo "In tmux, press 'prefix + I' to install tpm plugins."
