---
name: pkm-sync-setup
description: "How the PKM Obsidian vault syncs across machines — Syncthing + git, and why .git is excluded from Syncthing"
metadata: 
  node_type: memory
  type: project
  originSessionId: a0f99ca2-63ed-4b32-82d9-da49ee45e119
---

The PKM vault at `/home/pjf/pkm` (an Obsidian vault) syncs across machines two ways: **Syncthing** for live file sync, and **git** (`github.com:pjfitzgerald/pkm`, branch `master`) for version history/backup.

Syncthing folder ID is `ztety-fltwy`, label "PKM". `.git`, `.obsidian`, and `.DS_Store` are excluded from Syncthing via `.stignore` (which is git-tracked, so the rule reaches every machine that clones the repo). `.obsidian` is synced by git instead.

**Why:** Syncing `.git` internals between machines via Syncthing corrupts the repo and produces sync-conflict files (it had happened before — see the "clean up syncthing conflict files" commit). The two sync mechanisms must cover disjoint file sets.
**How to apply:** When onboarding a new machine, `git clone` the repo first, then point Syncthing at that clone. Never remove `.git` from `.stignore`. Keep git committed/pushed before letting Syncthing do an initial sync.

t480's Syncthing device ID: `ICJ63KK-AJ2JIC4-QDAZRTV-R5DNOEX-3TKL2CR-MR2B7LG-NYZAVAV-7GRPPAK` (Syncthing runs as a `systemctl --user` service; GUI at http://127.0.0.1:8384).
