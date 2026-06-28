# CLAUDE.md (User-level)

This file applies to all projects and provides global guidance to Claude Code.

## About Me

- I go by PJF
- ubuntu linux is my current primary development environment
- I also work in WSL and macOS (Apple Silicon) environments
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
- **Keep docs in sync with the change that triggered them.** When modifying a documented system or tool (Obsidian notes, CLAUDE.md files, READMEs, in-tool `--help` / usage text, memory files), update the relevant docs as part of the same change — don't defer to "later". Find every doc that references the thing you changed by searching for the feature/command/path/symbol name across likely locations (project docs, user-level CLAUDE.md, vault zettelkasten, memory dir). Skip only when the change is purely internal (refactor, dead-code removal, comment edits) and a doc reader wouldn't notice. If the doc surface to update is large or ambiguous, flag it and ask before sprawling.
- **End-of-turn summaries: restate each question/task with its answer.** When PJF's prompt contains multiple questions or tasks (typically a bulleted or dashed list), the end-of-turn summary should briefly restate each item alongside what I did/answered. This means he can read the summary top-to-bottom without scrolling back to re-load the question context. One terse line per item is enough — keep prose minimal, but make the restatement explicit. Format: short paraphrase of the question/task in bold (or as the lead clause), then the answer/result on the same line or immediately below. For single-task prompts, the existing concise direct summary is fine — don't manufacture restatement when there's only one thing.

## Tools & Stack

- Package manager: Homebrew (Apple Silicon, /opt/homebrew)
- Node version manager: nvm
- Languages: Python, TypeScript, Ruby, Lua
- LSP servers: pyright, ts_ls, ruby_lsp, lua_ls
