# CLAUDE.md (User-level)

This file applies to all projects and provides global guidance to Claude Code.

## About Me

- I go by PJF
- macOS (Apple Silicon) is my primary development environment
- I also work in WSL environments
- Editor: Neovim (kickstart.nvim-based config)
- Terminal multiplexer: tmux
- Shell: zsh
- Dotfiles repo: ~/dotfiles

## Preferences

- Be concise and direct. Don't over-explain.
- When making changes, keep working until the goal is fully achieved rather than stopping to ask for confirmation at every step.
- When you discover issues or improvements during a task, fix them inline rather than just reporting them.
- Prefer editing existing files over creating new ones.
- Use Homebrew for package management on macOS.
- Do not add Co-Authored-By lines to git commits.

## Obsidian vault (`~/pkm`)

- PJF's Obsidian vault lives at `~/pkm`. Existing top-level folders: `01 projects` (with `01 active` / `02 inactive` / `03 ideas` / `04 archived`), `02 zettelkasten`, `03 reference`, `04 daily-notes`, `05 archive`, `07 leetcode`.
- **Default location for new notes**: the vault root (`~/pkm/`), unless the note belongs to a specific project — in which case place it inside that project's folder at `~/pkm/01 projects/01 active/<project>/`.
- Each active project has its own folder containing a hub note (`<project>.md`) plus any sub-notes. Within a project folder, prefix sub-notes with the project name (`<project> - <topic>.md`) to avoid wikilink collisions across the vault.
- Wikilinks in Obsidian resolve by filename, not path — so links like `[[pbudget]]` keep working regardless of folder location.

## Tools & Stack

- Package manager: Homebrew (Apple Silicon, /opt/homebrew)
- Node version manager: nvm
- Languages: Python, TypeScript, Ruby, Lua
- LSP servers: pyright, ts_ls, ruby_lsp, lua_ls
