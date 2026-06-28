---
name: project-memos
description: "Memos (lightweight note/memo service, usememos) runs on t480 — fully local SSD, SQLite, port 5230 (set up 2026-06-28)"
metadata:
  node_type: memory
  type: project
---

[Memos](https://github.com/usememos/memos) — a lightweight, self-hosted note/memo service. **Set up fresh on t480 on 2026-06-28** (not migrated from anywhere). Same profile as [[project_freshrss]]: a small SQLite app with no bulk data, so **everything lives on t480's local SSD** (`~/docker/memos/data`) — **no NFS** (SQLite must never run over NFS). Not the app-on-t480/data-on-NAS split used by Nextcloud/Paperless/Immich/*arr.

Compose at `~/docker/memos/docker-compose.yml`, image `neosmemo/memos:stable`, `container_name: memos`, `restart: unless-stopped`, `TZ=Australia/Melbourne`. Single volume `~/docker/memos/data:/var/opt/memos` (SQLite DB `memos_prod.db` + WAL live here; files owned by container uid 10001). Default SQLite driver, no external DB/redis. Served at `http://t480.astrapia-degree.ts.net:5230` (5230:5230, bound 0.0.0.0 so reachable over LAN/Tailscale). First-run web setup creates the admin/host account.

Backups: added to the n54l **services** restic job (2026-06-28). That job uses an **explicit per-service list** (not a `~/docker/*` glob), so new services must be registered: `memos` was added to both `SOURCES_ORDER` and the `SRC` map in n54l `~/ops/services-backup.sh` (`[memos]="t480:/home/pjf/docker/memos"`, grouped with freshrss). Picked up at the nightly 04:30 pull. Overview in [[project_homelab]].
