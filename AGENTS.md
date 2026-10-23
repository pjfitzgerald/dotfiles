# AGENTS.md

Guidance for any coding agent working in this repository. `CLAUDE.md` is a
symlink to this file — Claude Code only discovers that name.

## Overview

This is a personal dotfiles repository (`~/dotfiles`), used across macOS (personal) and WSL/Windows (work). The primary content is a **kickstart.nvim**-based Neovim configuration with custom modifications, plus shell, tmux/herdr, terminal, keyboard and coding-agent config.

## Coding agents

Config is split into an agent-neutral source of truth and thin per-agent
adapters. **`ai/README.md` is the reference** — read it before touching any of
this.

- `ai/` — instructions (`AGENTS.md`), skills, commands, subagents, memory,
  context injectors, MCP declarations. `install.sh` symlinks each into whatever
  path a given agent expects.
- `claude/`, `opencode/`, `codex/`, `gemini/` — adapters. Only harness settings
  that genuinely cannot be shared: model, permissions, TUI, hook wiring.
  Codex and Gemini are stubs; neither is installed here yet.

Two traps worth repeating from `ai/README.md`:

- **Claude Code does not read `AGENTS.md`** — it hardcodes `CLAUDE.md`
  discovery. So `AGENTS.md` is always the real file and `CLAUDE.md` is a
  symlink to it. That applies to this repo too: the file you are reading is
  `AGENTS.md`, and `CLAUDE.md` is a committed symlink (git mode 120000).
- **opencode reads two instruction paths**, its own `AGENTS.md` and
  `~/.claude/CLAUDE.md`, so `install.sh` links only the latter — linking both
  would load the same rules twice. There is no config key to turn one off; the
  env var that does it is all-or-nothing and would also stop opencode reading
  project-level `CLAUDE.md`. See `ai/README.md`.

Auth is one-time and never committed: `claude login`, `opencode auth login`
(OpenRouter).

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

## herdr (tmux alternative)

[herdr](https://herdr.dev) is a terminal workspace manager built around AI coding
agents. It is installed **alongside** tmux, not as a replacement — both configs
are live and either can be used.

- `herdr/config.toml` — the config, symlinked to `~/.config/herdr/config.toml` by
  `install.sh`. Note it symlinks the **file**, not the directory: herdr keeps its
  sockets, logs, and session state in `~/.config/herdr` too.
- Keybindings are a deliberate port of `tmux/tmux.conf` (prefix `C-Space`, the
  same kill/split/jump/swap keys), so the muscle memory carries over. Every place
  the port is imperfect is commented inline in `config.toml`.
- Terminology: a tmux **window** is a herdr **tab**; a tmux **session** is a herdr
  **workspace**.
- `bin/herdr-pkm`, `bin/herdr-join-pane`, `bin/herdr-clone-tab` — the tmux binds
  with no native herdr action (`prefix + P`, `prefix + J`, `prefix + C` /
  `prefix + M-c`), wired up as `[[keys.command]]` entries. `herdr-clone-tab` talks
  to the socket API directly (`layout.export` / `layout.apply`) because the CLI has
  no layout subcommand.
- `ai/context/herdr-agent-state.sh` + the `SessionStart` hook in
  `claude/settings.json` are herdr's Claude Code integration (agent state in the
  sidebar), installed by `herdr integration install claude`. Both files are
  symlinked into this repo, so its edits land here as tracked diffs. Upstream
  installs the hook script to `claude/hooks/`; under this repo's agent-neutral
  layout it lives in `ai/context/` instead, so re-running the installer will
  recreate the old path — move it back and fix the hook command in
  `claude/settings.json` if that happens.
- **C-hjkl navigation**: under tmux, vim-tmux-navigator's tmux half checks whether
  the focused pane runs nvim and forwards the key. herdr has no conditional
  binding, so nvim drives it instead — `multiplexer_navigate` in `nvim/init.lua`
  moves within nvim's splits and calls `herdr pane focus` only at the edge. From a
  non-nvim pane, use `ctrl+alt+hjkl` or `prefix+hjkl`.
- **Not ported**: tmux's `send-prefix` (no literal `C-Space` passthrough, so nvim's
  blink.cmp `<C-space>` is unreachable inside herdr), `display-panes` /
  `M-!..M-(` indexed pane jumps, last-window / last-session, and the
  `tdl`/`tds`/`tdlm`/`tsl` dev-layout functions in `zsh/zshrc` plus `bin/tmux-*`
  (still tmux-only).
- Docs for agents: `https://herdr.dev/llms.txt` (index), `herdr --skill` (pane and
  agent control from inside a pane), `herdr config check` (validates
  `config.toml` and reports which binding wins a conflict).

## kanata (home row mods)

[kanata](https://github.com/jtroo/kanata) is a cross-platform keyboard remapper used to set up home row mods (tap a/s/d/f/j/k/l/; for letters, hold for Ctrl/Shift/Alt/Super — mirrored GACS layout).

- `kanata/kanata.kbd` — the config, symlinked to `~/.config/kanata/kanata.kbd` by `install.sh`.
- `kanata/kanata.service` — systemd user unit for Linux autostart, symlinked to `~/.config/systemd/user/`.
- `kanata/dev.kanata.kanata.plist` — macOS LaunchDaemon template (installed manually — see the plist's header comment).
- `install.sh` installs the kanata binary and wires up `/dev/uinput` access + the systemd service automatically on native Linux.
- **Skipped under WSL**: WSL2 has no access to the host's raw keyboard input, so kanata there can't intercept physical keys. Home row mods on a WSL machine require running kanata natively on the Windows host instead (not covered by this repo).
- **macOS requires manual steps**: installing the Karabiner-DriverKit-VirtualHIDDevice driver and approving it in System Settings can't be scripted — `install.sh` prints the steps instead of running them.
- On Omarchy the live config is `~/.config/kanata/config.kbd` with a `SUPER+F1`
  toggle, set up outside this repo — see `ai/memory/kanata-home-row-mods.md`.

## Neovim Config Structure

The nvim config is based on [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) — a single-file starting point, not a distribution.

- `nvim/init.lua` — Main config file containing nearly all settings, keymaps, and plugin declarations. Custom additions are marked with `-- PJF:` comments.
- `nvim/lua/kickstart/plugins/` — Optional plugin modules (neo-tree is enabled; debug, indent_line, lint, autopairs, gitsigns are available but commented out in init.lua)
- `nvim/lua/custom/plugins/obsidian.lua` — The **single source of truth** for the obsidian.nvim spec (vault workflow, `<leader>o` keymaps, `<CR>` checkbox-cycle wrappers, weekly notes). Loaded via an explicit `require 'custom.plugins.obsidian'` in init.lua's plugin list — do NOT add a second obsidian spec to init.lua; lazy.nvim merges same-plugin specs and the resulting config-override shadowing is exactly how the visual checkbox toggle silently broke once.
- `nvim/lua/custom/plugins/{lualine,noice,snacks,trouble,omarchy-theme}.lua` — the Omarchy/LazyVim UI stack (statusline, notifications, Snacks, symbols breadcrumb, live theme sync). Each is `require`d explicitly in init.lua, in that order — snacks/noice/trouble must load before lualine, which renders their segments.
- `nvim/lua/custom/plugins/init.lua` — Empty, intended for user-added plugins. The `{ import = 'custom.plugins' }` line stays commented out: every module here is `require`d explicitly instead, and enabling the import as well loads each one a **second** time, which is the same-plugin-spec merge that broke the checkbox toggle. The work machine's branch still has that import enabled; if a merge brings it back, re-comment it.
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
- `multiplexer_navigate` drives `<C-hjkl>` across nvim splits and the outer multiplexer: under tmux it defers to vim-tmux-navigator's commands, under herdr (`HERDR_ENV=1`) it moves within nvim first and only calls `herdr pane focus` at the edge
- Nerd Font is enabled (`vim.g.have_nerd_font = true`) and `vim.g.trouble_lualine` gates the breadcrumb segment

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
