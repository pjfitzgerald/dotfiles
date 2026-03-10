#!/bin/bash
# Sets up symlinks for this dotfiles repo.
# Expects the repo to live at ~/dotfiles

set -e

DOTFILES="$HOME/dotfiles"

if [ ! -d "$DOTFILES" ]; then
  echo "Error: $DOTFILES does not exist. Clone the repo there first."
  exit 1
fi

# ~/.zshrc -> repo copy
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
  echo "Backing up existing .zshrc to .zshrc.bak"
  mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi
ln -sf "$DOTFILES/zshrc" "$HOME/.zshrc"

# ~/.config/nvim -> repo copy
mkdir -p "$HOME/.config"
if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
  echo "Backing up existing nvim config to ~/.config/nvim.bak"
  mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%s)"
fi
ln -sfn "$DOTFILES/nvim" "$HOME/.config/nvim"

# ~/.config/tmux -> repo copy
if [ -d "$HOME/.config/tmux" ] && [ ! -L "$HOME/.config/tmux" ]; then
  echo "Backing up existing tmux config to ~/.config/tmux.bak"
  mv "$HOME/.config/tmux" "$HOME/.config/tmux.bak.$(date +%s)"
fi
ln -sfn "$DOTFILES/tmux" "$HOME/.config/tmux"

# ~/.aliases -> repo copy
ln -sf "$DOTFILES/aliases" "$HOME/.aliases"

# ~/bin/dev
mkdir -p "$HOME/bin"
ln -sf "$DOTFILES/bin/dev" "$HOME/bin/dev"

echo "Done. Restart your shell or run: source ~/.zshrc"
