#!/bin/bash
# Sets up dotfiles and installs dependencies.
# Expects the repo to live at ~/dotfiles

set -e

DOTFILES="$HOME/dotfiles"

if [ ! -d "$DOTFILES" ]; then
  echo "Error: $DOTFILES does not exist. Clone the repo there first."
  exit 1
fi

# On macOS, ensure Homebrew is on PATH (common for Apple Silicon)
if [[ "$(uname)" == "Darwin" ]]; then
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# Detect package manager
if command -v brew &>/dev/null; then
  PKG_MANAGER="brew"
elif command -v pacman &>/dev/null; then
  PKG_MANAGER="pacman"
elif command -v apt &>/dev/null; then
  PKG_MANAGER="apt"
else
  PKG_MANAGER="unknown"
  echo "Warning: could not detect a supported package manager. Skipping installs."
fi

install_pkg() {
  local pkg=$1
  echo "Installing $pkg..."
  case "$PKG_MANAGER" in
    brew)   brew install "$pkg" ;;
    pacman) sudo pacman -S --noconfirm "$pkg" ;;
    apt)    sudo apt-get install -y "$pkg" ;;
  esac
}

# Install zsh
if ! command -v zsh &>/dev/null; then
  install_pkg zsh
fi

# Install fzf
if ! command -v fzf &>/dev/null; then
  install_pkg fzf
fi

# Install tmux
if ! command -v tmux &>/dev/null; then
  install_pkg tmux
fi

# Install neovim
if ! command -v nvim &>/dev/null; then
  install_pkg neovim
fi

# Install zsh-syntax-highlighting
if [ "$PKG_MANAGER" = "brew" ]; then
  brew list zsh-syntax-highlighting &>/dev/null || brew install zsh-syntax-highlighting
elif [ "$PKG_MANAGER" = "pacman" ]; then
  pacman -Q zsh-syntax-highlighting &>/dev/null || sudo pacman -S --noconfirm zsh-syntax-highlighting
elif [ "$PKG_MANAGER" = "apt" ]; then
  dpkg -l zsh-syntax-highlighting &>/dev/null || sudo apt-get install -y zsh-syntax-highlighting
fi

# Set zsh as default shell
ZSH_PATH=$(command -v zsh)
if [ "$SHELL" != "$ZSH_PATH" ]; then
  echo "Setting default shell to zsh..."
  if ! grep -q "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
  fi
  chsh -s "$ZSH_PATH"
fi

# Symlinks
echo "Creating symlinks..."

if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
  echo "Backing up existing .zshrc to .zshrc.bak"
  mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi
ln -sf "$DOTFILES/zshrc" "$HOME/.zshrc"

mkdir -p "$HOME/.config"

if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
  echo "Backing up existing nvim config to ~/.config/nvim.bak"
  mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%s)"
fi
ln -sfn "$DOTFILES/nvim" "$HOME/.config/nvim"

if [ -d "$HOME/.config/tmux" ] && [ ! -L "$HOME/.config/tmux" ]; then
  echo "Backing up existing tmux config to ~/.config/tmux.bak"
  mv "$HOME/.config/tmux" "$HOME/.config/tmux.bak.$(date +%s)"
fi
ln -sfn "$DOTFILES/tmux" "$HOME/.config/tmux"

ln -sf "$DOTFILES/aliases" "$HOME/.aliases"

mkdir -p "$HOME/bin"
ln -sf "$DOTFILES/bin/dev" "$HOME/bin/dev"

# Claude Code config
mkdir -p "$HOME/.claude"
ln -sf "$DOTFILES/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
ln -sf "$DOTFILES/claude/settings.json" "$HOME/.claude/settings.json"
mkdir -p "$HOME/.claude/projects/-Users-$(whoami)"
ln -sfn "$DOTFILES/claude/memory" "$HOME/.claude/projects/-Users-$(whoami)/memory"

echo ""
echo "Done! Open a new terminal to start using zsh."
