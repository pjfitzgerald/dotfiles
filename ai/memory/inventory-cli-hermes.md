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
- Two prod deployments, **separate and unsynced** databases: t480 over
  Tailscale (`https://inventory.astrapia-degree.ts.net/api/v1`) holds the real
  ~650 items; Railway (`https://inventory.optimisedthought.com/api/v1`) is the
  CLI's built-in default and is near-empty. Pick with `INVENTORY_API_URL`; PJF chose to stay on the Railway default on omarchy-1 (2026-10-23).
- As of 2026-10-23: t480 was offline, the CLI was not logged in on omarchy-1,
  and Hermes had no inference provider configured (`hermes -z` errors out).
- Docs: `~/pkm/projects/01 active/inventory/inventory -- cli usage.md`.
