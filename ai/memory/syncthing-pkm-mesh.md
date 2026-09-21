---
name: syncthing-pkm-mesh
description: "Syncthing setup syncing the ~/pkm PKM folder across the user's devices"
metadata: 
  node_type: memory
  type: project
  originSessionId: f0f3b34b-1cf0-4223-a19c-c4a7b542d6dd
  modified: 2026-09-01T22:30:18.196Z
---

The user syncs their PKM notes folder via Syncthing. Folder ID `ztety-fltwy` (label "PKM"), path `~/pkm` on each box.

Devices in the mesh (Syncthing device names / ID prefixes):
- `omarchy` (`OC3LEDU…`) — main Arch/Omarchy desktop, syncthing v2.1.3, user service + linger enabled, GUI at 127.0.0.1:8384
- `t480` (`ICJ63KK…`) — Debian laptop, syncthing v1.29.5, reachable as `ssh t480` over Tailscale (key auth set up 2026-09-02), config at ~/.local/state/syncthing/
- `pixel9a` (`QXHPFI5…`) — Android
- `MBP-292` / `mbp` (`QIXE4LV…`) — macOS

As of 2026-09-02 the omarchy↔t480 pair was fully synced. omarchy also pairs with pixel9a; MBP shares the folder on t480's side.

**How to apply:** To inspect status use the REST API: `curl -H "X-API-Key: <apikey from config.xml>" http://127.0.0.1:8384/rest/db/status?folder=ztety-fltwy` (the `syncthing cli show folder-status` subcommand does not exist in v2). Related: [[omarchy-ssh-no-agent]].
