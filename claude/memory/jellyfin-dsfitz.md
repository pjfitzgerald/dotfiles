---
name: jellyfin-dsfitz
description: "PJF's Jellyfin server — runs on t480 (NOT dsfitz; that instance was decommissioned 2026-06-21). Media read over NFS; NAS dir-permission gotcha that hides libraries."
metadata:
  node_type: memory
  type: project
  originSessionId: 47376f41-52fe-4bdc-b743-517d9f94b53b
  modified: 2026-08-01T22:03:18.084Z
---

Jellyfin is PJF's **primary** media player (Plex kept as backup, still on dsfitz:32400).

**It runs on the t480, not dsfitz.** The dsfitz Jellyfin was decommissioned 2026-06-21 — don't
go looking for it there. Compose lives at **`~/jellyfin/docker-compose.yml`** (note: `~/jellyfin`,
*not* the usual `~/docker/<service>/` pattern). Host networking, `user: "1000:1000"`, `/dev/dri`
passed through for QuickSync HW transcode. Media is dsfitz's `/volume2/data/media`, mounted
read-only on the t480 at `/mnt/dsfitz-data/media` → `/media:ro` in the container.

- **LAN:** `http://192.168.8.228:8096` · **Remote:** `http://t480.astrapia-degree.ts.net:8096`
- **Config:** `~/jellyfin/config`; DB at `config/data/jellyfin.db`; logs `config/log/`.
- **Admin user `pjf`** — password was regenerated during the t480 build and is NOT the old
  dsfitz one; no API keys exist in the DB, so API access needs PJF to supply it.
- Libraries: Movies←movies · Shows←tv+daily-wire · Music←music · Comedy←comedy ·
  Documentaries←documentaries · Sport←sport · YouTube←youtube · Misc←misc

**Gotcha — silently missing library items = NAS directory permissions.** Jellyfin runs as
uid 1000; media dirs on dsfitz created as `patrick_admin` (uid 1026) mode `0700` are unreadable,
so the scan skips them *and still reports "Completed"* — no error anywhere. Found 2026-07-31
with 433/470 movie folders hidden this way. Detect + fix on dsfitz:
`find /volume2/data/media -type d \( -perm -u+rwx -a ! -perm -g+rx \) -user patrick_admin -exec chmod 755 {} +`

**Debugging without credentials:** read `config/data/jellyfin.db` via Python's `sqlite3` with a
`?mode=ro` URI (no `sqlite3` CLI on the t480) — table `BaseItems`, `Type='MediaBrowser.Controller.Entities.Movies.Movie'`,
diff `Path` against the filesystem to find what didn't index.

Full write-up: `~/pkm/zettelkasten/jellyfin on t480 quicksync.md`. See [[project-homelab]],
[[t480-server]], [[reference_dsfitz]].
