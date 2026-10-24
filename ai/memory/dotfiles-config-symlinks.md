---
name: dotfiles-config-symlinks
description: ~/dotfiles is the source of truth and ~/.config holds only symlinks; per-machine variants are omarchy-<name> files picked by $IS_OMARCHY in install.sh
metadata:
  type: project
---

`~/dotfiles` is the source of truth; `~/.config` holds only symlinks into it,
created by `install.sh`. A config that is a *real file* under `~/.config` has
drifted out of the repo and will be clobbered on the next `install.sh` run.

Per-machine splits are two files in the repo, selected by `$IS_OMARCHY`
(detected via `/usr/share/omarchy-zsh/shell/zoptions`): `<name>` for
macOS/WSL, `omarchy-<name>` for Omarchy — `zsh/`, `kitty/`, `ghostty/`.
Omarchy-only, no mac counterpart: `alacritty/`, `foot/`, `hypr/`.

**Why:** Omarchy terminal configs carry a
`~/.local/state/omarchy/current/theme/...` import that the mac configs lack.
Linking a mac config on Omarchy silently unthemes the terminal — which is how
kitty/ghostty/alacritty/foot had drifted into untracked real files by
2026-10-25, when this was reconciled.

**How to apply:** Edit the repo file, not the live one. New config dir needs a
`.gitignore` whitelist entry (deny-by-default `*`). `~/.config/hypr/monitors.lua`
is machine-local and deliberately untracked — don't add it. Link whole dirs only
where we own every file (`nvim/`, `tmux/`); per-file symlinks where another tool
also writes (`hypr/`, `herdr/`, `~/.claude/skills/`). Kanata's config is
`kanata/config.kbd`, not `kanata.kbd`. Open item: `tmux/tmux.conf` and the live
omarchy tmux.conf have diverged ~420 lines and still need a manual merge.
See `<vault>/zettelkasten/dotfiles.md` and [[kanata-home-row-mods]].
