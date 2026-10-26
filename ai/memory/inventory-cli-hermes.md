---
name: inventory-cli-hermes
description: Inventory CLI install on omarchy-1 + the Hermes skill that hooks it in; two unsynced prod DBs
metadata:
  type: project
---

The `inventory` CLI (personal item tracker) is installed on omarchy-1 as
`~/.local/bin/inventory` → `~/code/projects/inventory/api/cli/inventory` (the
standalone stdlib-only script, not the Thor `bin/inventory` dev wrapper).
Hooked into Hermes as a local skill at `~/.hermes/skills/inventory-cli/SKILL.md`
(added 2026-10-23).

**Why:** PJF built the CLI so agents could act on the inventory DB over HTTP.

**How to apply:**
- The skill is named `inventory-cli`, not `inventory` — a community clawhub
  skill owns the name `inventory` and `hermes skills inspect inventory`
  resolves to that one instead.
- Two prod deployments, **separate and unsynced** databases. Railway
  (`https://inventory.optimisedthought.com/api/v1`) is the CLI's built-in
  default and holds the real data — 721 items, 709 under
  `patrick.fitzgerald29@gmail.com` (verified 2026-10-23 against its Postgres;
  older notes calling it "empty" are stale). t480 over Tailscale
  (`https://inventory.astrapia-degree.ts.net/api/v1`) is the other, diverged
  copy, and t480 is often offline.
- **Railway runs `origin/master`, which lags the dev branch**: no shared
  inventories, no recycle bin, no `sublocation`, and `delete` there is a
  **hard, unrecoverable delete**. Don't trust the CLI's own `--help` about
  what the server supports.
- Railway access for debugging: `railway link --project inventory` (renamed
  from `kind-magic`), then `railway variable list --service Postgres --json`
  for `DATABASE_PUBLIC_URL` and psql straight in. No SSH key is registered on
  omarchy-1, so `railway ssh` doesn't work there.
- Login returning `Invalid email or password` means wrong password, not a
  missing account — the API returns that same string for both, but an
  unverified email gets a distinct 403 instead. The two prods have separate
  `users` tables, so passwords differ between them.
- As of 2026-10-23 the CLI was not logged in on omarchy-1 and Hermes had no
  inference provider configured (`hermes -z` errors out).
- Docs: `~/pkm/projects/01 active/inventory/inventory -- cli usage.md`.
