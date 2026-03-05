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
eval "$(dircolors -b)"
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Git aliases
alias gst='git status'
alias gl='git log'

ga() { git add "$@"; }
gco() { git checkout "$@"; }
gc() { git commit "$@"; }
gp() { git push "$@"; }
gd() { git diff "$@"; }

# Ensure native Linux Node.js/npm is used instead of Windows version
export PATH="$(echo "$PATH" | tr ':' '\n' | grep -v '/mnt/c/Program Files/nodejs' | tr '\n' ':' | sed 's/:$//')"

export NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt

# Prefer /usr/local/bin (Neovim nightly)
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# FZF - show hidden files
export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/\.git/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
