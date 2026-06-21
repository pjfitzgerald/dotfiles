---
name: project-nextcloud
description: Nextcloud runs on t480 (not dsfitz) with data on dsfitz over NFS
metadata: 
  node_type: memory
  type: project
  originSessionId: b3129d94-2d62-4012-8890-8f5bd05bfb5e
---

Nextcloud (set up 2026-06-18) runs as a Docker stack on **t480**, not on the dsfitz Synology, because the DS1821+ has only 3.8 GB RAM and OOM/swap-thrashed when Nextcloud was installed alongside its existing media/photos stack. App + MariaDB + Redis are on t480's local SSD (`~/docker/nextcloud/`); the user-data dir lives on dsfitz at `/volume2/docker/nextcloud/data` mounted over **NFS** (Docker `local`-driver NFS volume, LAN addr 192.168.8.184). Reached at `http://t480.astrapia-degree.ts.net:11000`; admin creds in `~/docker/nextcloud/.env`.

Key gotcha for future work: **dsfitz is RAM-constrained (3.8 GB)** — don't add heavy stacks there; t480 (22 GB) is the place for new RAM-hungry services. Redis transactional locking makes the NFS data dir safe.

Full doc: `~/pkm/zettelkasten/nextcloud setup on t480.md`. Overview in [[project_homelab]]; same app-on-t480/data-on-NAS pattern as [[project_paperless]]. Related: PKM sync [[project_pkm_sync]].
