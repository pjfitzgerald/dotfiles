---
name: project-paperless
description: Paperless-ngx runs on t480 (OCR/DB) with documents on dsfitz over NFS
metadata:
  node_type: memory
  type: project
  originSessionId: a0bf2c90-0a99-488d-a35a-1d97d65eb238
---

Paperless-ngx (migrated 2026-06-21) runs as a Docker stack on **t480**, not dsfitz, because the DS1821+ (3.8 GB RAM, ~21 containers) was swap-thrashing and OCR was starved — diagnosis was RAM/IO pressure, not paperless or CPU. Compose + **SQLite DB + Whoosh index live on t480's local SSD** (`~/docker/paperless/`, secrets in `.env` mode 600); **documents (media), consume, and export live on dsfitz** at `/volume2/docker/paperless/*` mounted as Docker `local`-driver **NFS volumes** (LAN addr 192.168.8.184, nfsv3). Reached at `http://t480.astrapia-degree.ts.net:8000`.

Key gotchas: (1) **SQLite must stay local — never on NFS** (locking/corruption); only bulk media is on the NAS. (2) **inotify doesn't work over NFS**, so the consumer uses `PAPERLESS_CONSUMER_POLLING=30` + `PAPERLESS_CONSUMER_IGNORE_PATTERNS` to skip Synology/macOS cruft (`@eaDir`, `@Syno*`, `.DS_Store`). (3) Container runs as `USERMAP_UID=1026/GID=100` to match existing NFS file ownership. The old dsfitz container is left stopped with `restart=no` — don't restart it (second writer). Backups not yet wired into [[t480 ops tooling]].

Full doc: `~/pkm/zettelkasten/paperless setup on t480.md`. Same pattern as [[project_nextcloud]]; overview in [[project_homelab]].
