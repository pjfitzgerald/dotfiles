# AGENTS.md (User-level)

This file applies to all projects and provides global guidance to any AI coding
agent working on PJF's machine. It is the single source of truth, living at
`~/dotfiles/ai/AGENTS.md`; `install.sh` symlinks it to `~/AGENTS.md`,
`~/.claude/CLAUDE.md`, `~/.config/opencode/AGENTS.md`, `~/.codex/AGENTS.md` and
`~/.gemini/GEMINI.md`.

Keep it agent-neutral: name capabilities ("the web-fetch tool"), not one
harness's tool names. Harness-specific settings belong in that agent's adapter
file under `~/dotfiles/<agent>/`. See `~/dotfiles/ai/README.md`.

## About Me

- I go by PJF
- Ubuntu Linux is my current primary development environment (hostname: t480)
- Also work in WSL and macOS (Apple Silicon)
- Editor: Neovim (kickstart.nvim-based config)
- Terminal multiplexer: tmux
- Shell: zsh
- Dotfiles repo: ~/dotfiles

## Conciseness — strictly enforced

**Concise responses are strictly better than verbose ones. This is non-negotiable.**

Short responses are easier to consume, less fatiguing, and keep PJF in flow. Long responses break momentum and slow progress in all directions. Conciseness also drives a learning feedback cycle: terse, high-signal answers function like spaced repetition, helping PJF absorb and retain information faster. Verbose responses smother that effect.

Be as concise as possible without withholding critical information — every word must earn its place. Do not over-explain, do not pad, do not restate context PJF already has. If a one-line answer suffices, give one line.

## Preferences

- Don't fix a reported problem on an assumed diagnosis — confirm the actual symptom first (ask or verify directly) before implementing a fix. Once the symptom is confirmed, proceed without hand-holding.
- When making changes, keep working until the goal is fully achieved rather than stopping to ask for confirmation at every step.
- Fix issues discovered during a task inline rather than just reporting them.
- Prefer editing existing files over creating new ones.
- Do not add Co-Authored-By lines to git commits.
- Use Homebrew for package management on macOS.

## Tools & Stack

- Package manager: Homebrew (Apple Silicon, /opt/homebrew)
- Node version manager: nvm
- Languages: Python, TypeScript, Ruby, Lua
- LSP servers: pyright, ts_ls, ruby_lsp, lua_ls

## Obsidian vault (`~/pkm`)

- PJF's Obsidian vault lives at `~/pkm`. Top-level folders: `projects` (sub: `01 active`, `02 inactive`, `03 ideas`, `04 archived`), `zettelkasten`, `daily notes`, `weekly notes`. Top-level folders are NOT number-prefixed — only `projects/` subfolders are.
- Default location for new notes: vault root (`~/pkm/`) unless the note belongs to a project → `~/pkm/projects/01 active/<project>/`.
- Never commit the vault (`git add`/`git commit` in `~/pkm`) unless PJF explicitly asks.
- Each project has a hub note (`<project>.md`) plus sub-notes prefixed with the project name (`<project> - <topic>.md`).
- Wikilinks resolve by filename, not path.

## Self-hosted homelab

Two main nodes + off-site backup:

- **dsfitz** — Synology DS1821+ NAS. Storage/RAID/backup node. RAM-constrained (3.8 GB) — don't add heavy stacks here. LAN 192.168.8.184, Tailscale.
- **t480** — ThinkPad, always-on server (22 GB RAM, Ubuntu). Compute node. LAN 192.168.8.228, tailnet 100.113.63.44. Not a laptop — don't raise sleep/suspend/battery concerns.
- **n54l** — HP ProLiant, off-site backup target. Ubuntu 24.04, `/backups` RAID1 2×3 TB.

Architecture pattern: app + DB on t480 local SSD, bulk data on dsfitz over NFS (Docker local-driver NFS volumes). Compose stacks in `~/docker/<service>/`. Verify live state with `docker ps` / `ssh dsfitz` before assuming.

## WebEOC / weboard work — global rules

These apply to any client board project (CSG, DPIRD, NTFES, QFD, sa-ses, watercorp, AgVic, and any future ones).

### Never run `weboard push` or `weboard pull` without asking

`weboard dev` (file-watcher / live-sync) and `weboard push` / `weboard pull` use the same upload/download pipeline. Running them concurrently can race and corrupt state.

- Before suggesting OR running `weboard push`, `weboard pull`, or anything that uses the same pipeline, **ask first**: "OK to run `weboard push <asset>` — is `weboard dev` running?" Wait for the green light.
- Same principle for `webeoc-lists push`.
- Exception: PJF himself running `weboard dev` is fine.

### Pushing board lists — use `webeoc-lists`, not `weboard`

Board lists (`lists/*.json`) are pushed with the **`webeoc-lists`** CLI, NOT `weboard`. Push a single list:

```
webeoc-lists push lists/<Name>.json --overwrite --url "$WE_URL" --username "$WE_USER" --password "$WE_PASSWORD"
```

`--overwrite` is **required** to update an existing list. `--url` is the base `WE_URL` from `.env`, NOT `.../api/rest.svc`. Same caution as `weboard push` — ask first.

**GOTCHA:** a bare `webeoc-lists pull` downloads _every_ list on the server into `lists/` — ~100 untracked files. To verify a single pushed list, pull into a throwaway scratch dir, never a bare pull in the repo.
