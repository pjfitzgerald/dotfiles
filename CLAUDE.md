# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal dotfiles repository (`~/dotfiles`), used across macOS (personal) and WSL/Windows (work). The primary content is a **kickstart.nvim**-based Neovim configuration with custom modifications, plus shell, tmux, and Claude Code config.

## Neovim Config Structure

The nvim config is based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) — a single-file starting point, not a distribution.

- `nvim/init.lua` — Main config file containing nearly all settings, keymaps, and plugin declarations. Custom additions are marked with `-- PJF:` comments.
- `nvim/lua/kickstart/plugins/` — Optional plugin modules (neo-tree is enabled; debug, indent_line, lint, autopairs, gitsigns are available but commented out in init.lua)
- `nvim/lua/custom/plugins/init.lua` — Empty, intended for user-added plugins (currently unused; the `{ import = 'custom.plugins' }` line is also commented out)
- `nvim/lazy-lock.json` — Plugin lockfile (managed by lazy.nvim)

## Custom Modifications (PJF)

All custom changes in `init.lua` are marked with `-- PJF:` comments:

- `<leader>e` toggles Neo-tree file browser
- `<leader>y`/`<leader>p` mappings for system clipboard copy/paste
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
