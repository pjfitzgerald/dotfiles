# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal dotfiles repository (`~/dotfiles`), used across macOS (personal) and WSL/Windows (work). The primary content is a **kickstart.nvim**-based Neovim configuration with custom modifications, plus shell, tmux, and Claude Code config.

## opencode

[opencode](https://opencode.ai) is set up to **coexist** with Claude Code (not replace it). It reuses the Claude config to avoid duplication:

- **Rules** — opencode falls back to `~/.claude/CLAUDE.md` (the user-level rules). No `~/.config/opencode/AGENTS.md` exists, on purpose, so that file stays the single source of truth.
- **Skills** — opencode reads `~/.claude/skills/*/SKILL.md` natively, so all custom skills load unchanged.
- **opencode-specific config** lives in `opencode/` and is symlinked to `~/.config/opencode/` by `install.sh`:
  - `opencode/opencode.json` — provider/model (OpenRouter) and permissions.
  - `opencode/tui.json` — theme (`tokyonight`, matching nvim) and TUI prefs.
- **Auth** is one-time and not committed: `opencode auth login` → OpenRouter.
- **Not ported:** Claude Code harness features with no opencode equivalent (voice, push notifications, Anthropic-shipped commands like `/code-review`, `/loop`), and the `claude/memory/` recall system (no native opencode equivalent — skipped for now).

## Terminals

Primary terminals are **iTerm2** (macOS) and **ghostty**; kitty is installed but
secondary. Most work happens over SSH from the Mac into the Linux boxes, which
is where both of the gotchas below bite.

- `ghostty/config` is symlinked by `install.sh` to
  `~/Library/Application Support/com.mitchellh.ghostty/config` on macOS, or
  `~/.config/ghostty/config` on Linux. **The file must be named exactly
  `config`** -- Ghostty silently ignores `config.ghostty`, which is what an
  editor opened via Cmd+, tends to save.
- `kitty/kitty.conf` is symlinked by `install.sh` to `~/.config/kitty/kitty.conf`
  on both platforms. On macOS kitty *also* reads
  `~/Library/Preferences/kitty/kitty.conf`, which shadows the symlink if it
  exists -- `install.sh` warns about it.
- **Option-as-Alt is the load-bearing setting, and every terminal spells it
  differently.** Without it macOS Option composes Unicode (`Option+s` -> `ß`),
  so every Alt-based tmux binding in `tmux/tmux.conf` (the `M-s`/`M-w` pickers,
  `M-1`..`M-9` window jumps, `M-S-<n>` pane jumps, the `M-arrow` chords) types
  text instead of firing. ghostty: `macos-option-as-alt = true`. kitty:
  `macos_option_as_alt yes` (kitty's default is `no`). iTerm2: Profiles -> Keys
  -> "Left Option key: Esc+". Use the `left`-only variant if right-Option should
  keep composing accents.
- **terminfo does not travel over SSH.** ghostty and kitty ship custom entries
  (`xterm-ghostty`, `xterm-kitty`); a remote host without them fails with
  `missing or unsuitable terminal`. Ubuntu's `ncurses-term` has `ghostty` but
  not the `xterm-ghostty` alias, and needs `kitty-terminfo` for kitty. Either
  install those remotely, or use `kitten ssh` / ghostty's `ssh-terminfo`, which
  push the entry across for you.
- tmux 3.6 has no built-in feature table for ghostty or kitty (only iTerm2 and
  foot), so `tmux/tmux.conf` declares `terminal-features` for both explicitly.
  Those are read at *client attach* time -- `source-file` alone won't apply them.

## Neovim Config Structure

The nvim config is based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) — a single-file starting point, not a distribution.

- `nvim/init.lua` — Main config file containing nearly all settings, keymaps, and plugin declarations. Custom additions are marked with `-- PJF:` comments.
- `nvim/lua/kickstart/plugins/` — Optional plugin modules (neo-tree is enabled; debug, indent_line, lint, autopairs, gitsigns are available but commented out in init.lua)
- `nvim/lua/custom/plugins/obsidian.lua` — The **single source of truth** for the obsidian.nvim spec (vault workflow, `<leader>o` keymaps, `<CR>` checkbox-cycle wrappers, weekly notes). Loaded via an explicit `require 'custom.plugins.obsidian'` in init.lua's plugin list — do NOT add a second obsidian spec to init.lua; lazy.nvim merges same-plugin specs and the resulting config-override shadowing is exactly how the visual checkbox toggle silently broke once.
- `nvim/lua/custom/plugins/init.lua` — Empty, intended for user-added plugins (the `{ import = 'custom.plugins' }` line is commented out; modules are required explicitly instead, as with obsidian.lua)
- `nvim/lazy-lock.json` — Plugin lockfile (managed by lazy.nvim)

## Custom Modifications (PJF)

All custom changes in `init.lua` are marked with `-- PJF:` comments:

- `<leader>e` toggles Neo-tree file browser
- `<leader>y`/`<leader>p` mappings for system clipboard copy/paste
- `<leader>df` prompts for two file paths and opens them in codediff.nvim (`:CodeDiff file`)
- `NODE_EXTRA_CA_CERTS` environment variable set to work around corporate proxy SSL certificate issues
- GitHub Copilot plugin added (accepts suggestions with `<C-l>`, Tab is not mapped to avoid conflict with blink.cmp)
- LSP servers configured: `pyright`, `ts_ls`, `ruby_lsp`, `lua_ls`
- `vim-rails` plugin added

## Formatting

Lua files are formatted with **stylua**. Config is in `nvim/.stylua.toml`:
- 160 column width, 2-space indentation, single quotes preferred, no call parentheses

To check formatting: `stylua --check nvim/`
To format: `stylua nvim/`

## Key Settings

- Leader key: `<Space>`
- Nerd Font: disabled (`vim.g.have_nerd_font = false`)
- Colorscheme: `tokyonight-night` (italics disabled in comments)
- Plugin manager: lazy.nvim
- Completion: blink.cmp (default keymap preset, `<c-y>` to accept)
- Autoformat on save via conform.nvim (disabled for C/C++)
