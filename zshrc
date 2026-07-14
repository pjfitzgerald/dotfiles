# Homebrew (Apple Silicon)
if [[ "$(uname)" == "Darwin" ]] && [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# History
HISTSIZE=999999999
SAVEHIST=999999999
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt APPEND_HISTORY

# Prompt: user@host:dir$ (matching bash theme colors)
autoload -U colors && colors
PROMPT='%B%F{green}%n@%m%f%b:%B%F{blue}%~%f%b$ '

# Set terminal title to user@host: dir
case "$TERM" in
xterm*|rxvt*)
    precmd() { print -Pn "\e]0;%n@%m: %~\a" }
    ;;
esac

# Color support
autoload -U compinit && compinit
if [[ "$(uname)" == "Darwin" ]]; then
  export CLICOLOR=1
  export LSCOLORS=GxFxCxDxBxegedabagaced
else
  eval "$(dircolors -b)"
  alias ls='ls --color=auto'
fi

# Grep
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# ls
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Git
alias gst='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gco='git checkout'
alias gb='git branch'
alias gr='git remote'
alias gl='git log'
alias gd='git diff'

# Directory shortcuts (shared)
alias dotfiles='cd ~/dotfiles'

# Pull dotfiles changes from work machine and re-run install
dotpull() {
  cd ~/dotfiles || return
  git remote get-url work &>/dev/null || git remote add work git@github.com:pfjuvare/dotfiles.git
  git fetch work && git merge work/master && ./install.sh
}

# WSL-specific
if [[ -d /mnt/c ]]; then
  # Strip Windows Node.js from PATH
  export PATH="$(echo "$PATH" | tr ':' '\n' | grep -v '/mnt/c/Program Files/nodejs' | tr '\n' ':' | sed 's/:$//')"
  # Corporate proxy CA certs
  export NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt

  # Work client directory shortcuts
  alias csg='cd ~/code/clients/CSG'
  alias ocrm='cd ~/code/clients/CSG/op-crm'
  alias dpird='cd ~/code/clients/DPIRD'
  alias dpirdrm='cd ~/code/clients/DPIRD/resource-management'
  alias dpirdpm='cd ~/code/clients/DPIRD/personnel-manager'
  alias ntfes='cd ~/code/clients/NTFES'
  alias qfd='cd ~/code/clients/QFD'
  alias qfpeople='cd ~/code/clients/QFD/people'
  alias sases='cd ~/code/clients/sa-ses'
  alias agvic='cd ~/code/clients/agvic'
  alias avops='cd ~/code/clients/agvic/boards/agvic-ops'
  alias watercorp='cd ~/code/clients/watercorp'
  alias wcdas='cd ~/code/clients/watercorp/boards/daily-awareness-system-rebuild/'
  alias wcww='cd ~/code/clients/watercorp/boards/waste-discharge-reporting-rebuild/'
  alias wcfaults='cd ~/code/clients/watercorp/boards/faults-register-rebuild/'
  alias pap='cd ~/code/clients/perth-airport/'

  # Juvare PKM (Obsidian vault on OneDrive)
  alias pkm='cd "/mnt/c/Users/patrick.fitzgerald/OneDrive - Juvare/Documents/juvare-pkm"'
fi

# macOS-specific
if [[ "$(uname)" == "Darwin" ]]; then
  # rbenv
  export PATH="${HOME}/.rbenv/bin:${PATH}"
  type -a rbenv > /dev/null 2>&1 && eval "$(rbenv init - zsh)"

  # Rails binstubs + node_modules binaries
  export PATH="./bin:./node_modules/.bin:${PATH}"

  # PostgreSQL (Homebrew)
  export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

  # Encoding
  export LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8

  # Prevent Homebrew from reporting
  export HOMEBREW_NO_ANALYTICS=1
fi

# PATH
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/dotfiles/bin:$PATH"

# Personal scripts (macOS)
if [[ "$(uname)" == "Darwin" ]] && [[ -d "$HOME/dev/scripts" ]]; then
  export PATH="$PATH:$HOME/dev/scripts"
fi

# FZF - show hidden files
export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/\.git/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Private aliases (not tracked in git)
[ -f "$HOME/dotfiles/aliases.local" ] && source "$HOME/dotfiles/aliases.local"

# Syntax highlighting (must be last)
if [ -f "$(brew --prefix 2>/dev/null)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Default editor (used by opencode's editor_open, git, etc.)
export EDITOR=nvim
export VISUAL=nvim

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# railway
export PATH="$HOME/.railway/bin:$PATH"
