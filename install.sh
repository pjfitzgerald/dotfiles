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

# Refresh the apt package index once before installing anything.
if [ "$PKG_MANAGER" = "apt" ]; then
  sudo apt-get update
fi

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

# Install TPM (Tmux Plugin Manager)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

# Install curl (needed below to fetch Neovim)
if ! command -v curl &>/dev/null; then
  install_pkg curl
fi

# Install ripgrep (Telescope live_grep, todo-comments)
if ! command -v rg &>/dev/null; then
  install_pkg ripgrep
fi

# Install fd (Telescope file finding) — Debian/Ubuntu names the package
# "fd-find" and the binary "fdfind", which Telescope autodetects.
if ! command -v fd &>/dev/null && ! command -v fdfind &>/dev/null; then
  if [ "$PKG_MANAGER" = "apt" ]; then
    install_pkg fd-find
  else
    install_pkg fd
  fi
fi

# Install Node.js + npm (Mason installs some LSP servers via npm).
# Debian/Ubuntu ship nodejs without npm, so install npm explicitly there.
if ! command -v node &>/dev/null; then
  case "$PKG_MANAGER" in
    brew)   install_pkg node ;;
    pacman) sudo pacman -S --noconfirm nodejs npm ;;
    apt)    sudo apt-get install -y nodejs npm ;;
  esac
elif ! command -v npm &>/dev/null; then
  case "$PKG_MANAGER" in
    brew)   install_pkg node ;;
    pacman) sudo pacman -S --noconfirm npm ;;
    apt)    sudo apt-get install -y npm ;;
  esac
fi

# Install a C compiler toolchain (telescope-fzf-native + treesitter parsers).
if ! command -v cc &>/dev/null && ! command -v gcc &>/dev/null; then
  case "$PKG_MANAGER" in
    brew)   xcode-select --install 2>/dev/null || true ;;
    pacman) sudo pacman -S --noconfirm base-devel ;;
    apt)    sudo apt-get install -y build-essential ;;
  esac
fi

# Install / upgrade Neovim — the nvim config requires >= 0.11. Distro repos
# (apt/pacman) often ship an older Neovim, so on Linux we install the official
# static build into ~/.local instead of using the package manager.
NVIM_VERSION="v0.12.2"
nvim_recent_enough() {
  command -v nvim &>/dev/null || return 1
  local v
  v=$(nvim --version | head -1 | sed -E 's/^NVIM v([0-9]+\.[0-9]+).*/\1/')
  [ "$(printf '%s\n0.11\n' "$v" | sort -V | head -1)" = "0.11" ]
}
if nvim_recent_enough; then
  echo "Neovim $(nvim --version | head -1 | awk '{print $2}') already installed."
elif [ "$PKG_MANAGER" = "brew" ]; then
  install_pkg neovim
else
  case "$(uname -m)" in
    x86_64|amd64)  nvim_arch="x86_64" ;;
    aarch64|arm64) nvim_arch="arm64" ;;
    *)             nvim_arch="" ;;
  esac
  if [ -z "$nvim_arch" ]; then
    echo "Warning: unsupported arch $(uname -m); install Neovim >= 0.11 manually."
  else
    echo "Installing Neovim $NVIM_VERSION to ~/.local..."
    nvim_tar="nvim-linux-${nvim_arch}.tar.gz"
    nvim_tmp=$(mktemp -d)
    curl -fsSL -o "$nvim_tmp/$nvim_tar" \
      "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${nvim_tar}"
    rm -rf "$HOME/.local/nvim-linux-${nvim_arch}"
    mkdir -p "$HOME/.local/bin"
    tar -xzf "$nvim_tmp/$nvim_tar" -C "$HOME/.local"
    ln -sfn "$HOME/.local/nvim-linux-${nvim_arch}/bin/nvim" "$HOME/.local/bin/nvim"
    rm -rf "$nvim_tmp"
    echo "Installed Neovim to ~/.local/bin/nvim (ensure ~/.local/bin is on PATH)."
  fi
fi

# Install clipboard tool (needed for tmux/neovim clipboard integration on Linux/WSL)
if [[ "$(uname)" == "Linux" ]] && ! command -v xclip &>/dev/null; then
  install_pkg xclip
fi

# Install opencode (terminal AI coding agent; coexists with Claude Code).
# Official installer drops the binary in ~/.opencode/bin.
if ! command -v opencode &>/dev/null && [ ! -x "$HOME/.opencode/bin/opencode" ]; then
  echo "Installing opencode..."
  curl -fsSL https://opencode.ai/install | bash
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

# Ghostty terminal config.
# Ghostty reads a file named exactly `config` -- an extension makes it invisible
# to Ghostty, which is a genuinely confusing failure mode, so warn about the
# common `config.ghostty` mistake rather than silently leaving it in place.
if [[ "$(uname)" == "Darwin" ]]; then
  GHOSTTY_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
else
  GHOSTTY_DIR="$HOME/.config/ghostty"
fi
mkdir -p "$GHOSTTY_DIR"
if [ -e "$GHOSTTY_DIR/config" ] && [ ! -L "$GHOSTTY_DIR/config" ]; then
  echo "Backing up existing ghostty config to config.bak"
  mv "$GHOSTTY_DIR/config" "$GHOSTTY_DIR/config.bak.$(date +%s)"
fi
ln -sf "$DOTFILES/ghostty/config" "$GHOSTTY_DIR/config"
if [ -e "$GHOSTTY_DIR/config.ghostty" ]; then
  echo "Note: $GHOSTTY_DIR/config.ghostty exists and is ignored by Ghostty; delete it."
fi

# Kitty terminal config. Same path on macOS and Linux. On macOS kitty also
# reads ~/Library/Preferences/kitty/kitty.conf, so warn if a real file is
# sitting there -- it would silently take precedence over this symlink.
KITTY_DIR="$HOME/.config/kitty"
mkdir -p "$KITTY_DIR"
if [ -e "$KITTY_DIR/kitty.conf" ] && [ ! -L "$KITTY_DIR/kitty.conf" ]; then
  echo "Backing up existing kitty config to kitty.conf.bak"
  mv "$KITTY_DIR/kitty.conf" "$KITTY_DIR/kitty.conf.bak.$(date +%s)"
fi
ln -sf "$DOTFILES/kitty/kitty.conf" "$KITTY_DIR/kitty.conf"
if [[ "$(uname)" == "Darwin" ]] && [ -e "$HOME/Library/Preferences/kitty/kitty.conf" ]; then
  echo "Note: ~/Library/Preferences/kitty/kitty.conf exists and shadows $KITTY_DIR/kitty.conf; delete it."
fi

# ---------------------------------------------------------------------------
# Coding agents.
#
# Everything portable lives in ai/ and is symlinked into each agent's expected
# path; only harness-specific settings live in the per-agent adapter dirs.
# See ai/README.md for the full mapping.
#
#   ai/AGENTS.md   instructions   (Claude Code only reads CLAUDE.md, hence the
#                                  symlink under that name)
#   ai/skills/     SKILL.md skills
#   ai/commands/   slash-command prompt bodies
#   ai/agents/     subagent definitions
#   ai/memory/     memory notes
#   ai/context/    stdin -> stdout context injectors (hook logic)
#   ai/mcp.json    MCP servers, applied by ai/bin/sync-mcp.sh
# ---------------------------------------------------------------------------
AI="$DOTFILES/ai"

# Home-level AGENTS.md, for agents that walk up from the project dir.
ln -sf "$AI/AGENTS.md" "$HOME/AGENTS.md"

# --- Claude Code -----------------------------------------------------------
mkdir -p "$HOME/.claude"
ln -sf  "$AI/AGENTS.md" "$HOME/.claude/CLAUDE.md"
ln -sfn "$AI/skills"    "$HOME/.claude/skills"
ln -sfn "$AI/commands"  "$HOME/.claude/commands"
ln -sfn "$AI/agents"    "$HOME/.claude/agents"
ln -sfn "$AI/context"   "$HOME/.claude/hooks"
ln -sf  "$DOTFILES/claude/settings.json" "$HOME/.claude/settings.json"
if [[ "$(uname)" == "Darwin" ]]; then
  CLAUDE_PROJECT_DIR="$HOME/.claude/projects/-Users-$(whoami)"
else
  CLAUDE_PROJECT_DIR="$HOME/.claude/projects/-home-$(whoami)"
fi
mkdir -p "$CLAUDE_PROJECT_DIR"
ln -sfn "$AI/memory" "$CLAUDE_PROJECT_DIR/memory"

# --- opencode --------------------------------------------------------------
# opencode loads its own AGENTS.md *and* ~/.claude/CLAUDE.md; both now resolve
# to ai/AGENTS.md, so opencode.json sets disableClaudeCodePrompt to avoid
# loading the same rules twice.
mkdir -p "$HOME/.config/opencode"
ln -sf  "$AI/AGENTS.md" "$HOME/.config/opencode/AGENTS.md"
ln -sfn "$AI/skills"    "$HOME/.config/opencode/skill"
ln -sfn "$AI/commands"  "$HOME/.config/opencode/command"
ln -sfn "$AI/agents"    "$HOME/.config/opencode/agent"
ln -sf  "$DOTFILES/opencode/opencode.json" "$HOME/.config/opencode/opencode.json"
ln -sf  "$DOTFILES/opencode/tui.json"      "$HOME/.config/opencode/tui.json"

# --- Codex (stub; not installed here yet) ----------------------------------
mkdir -p "$HOME/.codex"
ln -sf  "$AI/AGENTS.md" "$HOME/.codex/AGENTS.md"
ln -sfn "$AI/commands"  "$HOME/.codex/prompts"
ln -sf  "$DOTFILES/codex/config.toml" "$HOME/.codex/config.toml"

# --- Gemini CLI (stub; not installed here yet) -----------------------------
# Link both names: contextFileName in settings.json should make AGENTS.md work,
# but GEMINI.md is the built-in default, so this works either way.
mkdir -p "$HOME/.gemini"
ln -sf "$AI/AGENTS.md" "$HOME/.gemini/AGENTS.md"
ln -sf "$AI/AGENTS.md" "$HOME/.gemini/GEMINI.md"
ln -sf "$DOTFILES/gemini/settings.json" "$HOME/.gemini/settings.json"

# --- MCP servers -----------------------------------------------------------
bash "$AI/bin/sync-mcp.sh" || echo "Warning: MCP sync failed; run ai/bin/sync-mcp.sh manually."

echo ""
echo "Done! Open a new terminal to start using zsh."
