---
name: Obsidian vault access
description: Where the Obsidian vault lives on each machine, and how to read/write it
type: reference
---

The vault is the same content everywhere (Syncthing, folder id `ztety-fltwy`), but
the path differs per machine — resolve it before use rather than assuming:

- **Omarchy (omarchy-1), t480, macOS:** `~/pkm` — a real directory.
- **WSL / work:** `~/obsidian-vault` — a symlink to the OneDrive-synced Windows
  vault at `/mnt/c/Users/patrick.fitzgerald/OneDrive - Juvare/Documents/juvare-pkm`.
  **There is no `~/pkm` in WSL and there should never be one** — writing to
  `~/pkm/...` there silently creates a stray local directory OneDrive never
  syncs, so the note is effectively lost. If one appears, move its contents into
  the vault and remove it.

**Read and write vault files with ordinary file tools at the resolved path** —
NOT via an `mcp__obsidian-vault__*` filesystem MCP server.

**Why:** `@modelcontextprotocol/server-filesystem` implements the MCP roots
protocol, which makes the client override the server's CLI-configured directory
with the project CWD. So those tools end up restricted to the project directory
regardless of config. Known limitation as of 2026-03.

**Vault structure** differs between the two as well — check what exists instead
of creating a folder from the other machine's scheme:

- Personal (`~/pkm`): `projects/` (sub: `01 active`, `02 inactive`, `03 ideas`,
  `04 archived`), `zettelkasten`, `daily notes`, `weekly notes`. Top-level
  folders are NOT number-prefixed; only `projects/` subfolders are.
- Work: `01 projects/01 active/`, `01 daily-notes/`, `02 weekly-notes/`,
  `zettelkasten`, `reference`, `meetings`, `people`, `attachments`.

Both are organised primarily by **maps of content** rather than directories —
nearly all notes sit in `zettelkasten`, and e.g. the `clients` note links out to
each client, which in turn links to that client's project MOCs. Follow links
rather than assuming directory structure carries meaning. Related:
[[reference_obsidian_claude_moc]], [[project_pkm_sync]].
