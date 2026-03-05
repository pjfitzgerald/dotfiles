#!/bin/bash
# Sets up symlinks and dependencies for this dotfiles repo.
# Run after cloning/copying to ~/.config

set -e

DOTFILES="$HOME/.config"

# ~/.zshrc -> repo copy
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
  echo "Backing up existing .zshrc to .zshrc.bak"
  mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi
ln -sf "$DOTFILES/zshrc" "$HOME/.zshrc"

# ~/bin/dev
mkdir -p "$HOME/bin"
ln -sf "$DOTFILES/bin/dev" "$HOME/bin/dev"

echo "Done. Restart your shell or run: source ~/.zshrc"
