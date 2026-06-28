---
name: project-arr
description: Media automation *arr stack — Prowlarr/Sonarr/Radarr/Lidarr on t480, qBittorrent+Plex on dsfitz, shared /data over NFS
metadata:
  node_type: memory
  type: project
  originSessionId: 94abfca8-eec7-44aa-996d-cb4063cae61f
---

The media automation stack. Split across both homelab nodes (see [[project-homelab]]). **Verify live state** before assuming.

**t480** — the *arr apps run here in **`~/docker/arr/docker-compose.yml`** (project `arr`, one shared docker network so they resolve each other by container name): **Prowlarr** (9696), **Sonarr** (8989), **Radarr** (7878), **Lidarr** (8686). All linuxserver.io images, `PUID=1026/PGID=100`, TZ Australia/Melbourne. Config (SQLite DBs) on t480 local SSD at `~/docker/arr/config/<svc>`. Reach UIs at `192.168.8.228:<port>` (LAN/Tailscale).

**dsfitz** — keeps **qBittorrent** (download client, `192.168.8.184:8080`, user `admin`) and **Plex**, defined in `/volume2/docker/docker-compose.yml`. Bulk media + downloads live under `/volume2/data`.

**Storage / NFS** — single NFS volume `arr-data` → `:/volume2/data` mounted at **`/data`** in every *arr container (Docker `local` nfs driver, `addr=192.168.8.184,nfsvers=3,rw,hard,noatime,nolock`). Mounting at the *same* `/data` path the old dsfitz binds used keeps every path in the migrated DBs valid, and keeps `torrents/` + `media/` on one filesystem so Sonarr/Radarr **hardlink/atomic-move** imports work over NFS. The `/volume2/data` DSM export must stay **Read/Write + Squash "No mapping"** (uid 1026 → patrick_admin) or imports break — see [[project-homelab]] gotcha.

**Wiring** — Prowlarr fullSyncs indexers to Sonarr/Radarr/Lidarr (by container name `http://sonarr:8989` etc.). Sonarr/Radarr/Lidarr download client = qBittorrent at **`192.168.8.184`** (cross-host now; was the `qbittorrent` container name on dsfitz). Lidarr root folder `/data/media/music`; Sonarr/Radarr root folders under `/data/media/{tv,movies,...}`.

**FlareSolverr** — Cloudflare-protected indexers (e.g. **1337x**) need it. Added 2026-06-23 as a `flaresolverr` service in the same `arr/docker-compose.yml` (image `ghcr.io/flaresolverr/flaresolverr:latest`, port 8191, on `arr_default`). Prowlarr config: an Indexer Proxy of type FlareSolverr (`http://flaresolverr:8191/`) tagged `flaresolverr` (proxy id 1, tag id 1) — **any indexer that needs Cloudflare bypass must carry the `flaresolverr` tag** or Prowlarr won't route it through the proxy. Runs on t480 (headless Chrome is RAM-hungry; keep off dsfitz).

**Indexers** (as of 2026-06-24): two working, both tagged `flaresolverr`. **1337x** (id 3, baseUrl `1337x.st`) — also covers **music** for Lidarr (has an Audio category + music search), so it replaces the dead BitSearch. **EZTV** (id 1, baseUrl `eztvx.to`) — its homepage isn't Cloudflare-gated but its *search endpoint* is, so it fails ("blocked by CloudFlare Protection") until tagged `flaresolverr`; the Prowlarr schema does NOT flag EZTV as needing FlareSolverr, but in practice it does. **BitSearch removed** 2026-06-24 — its Cardigann definition was dropped from Prowlarr entirely (not in `/indexer/schema`, baseUrl empty), unfixable; deleted rather than left throwing health errors. **Mirror gotcha (1337x)**: `1337x.st` clears Cloudflare via FlareSolverr; `1337x.to` / `x1337x.ws` / `x1337x.eu` are *hard-blocked even through FlareSolverr*. Add a Cardigann indexer via API by POSTing its `/indexer/schema` entry with `appProfileId` set (e.g. 1), `tags:[1]`, and the `baseUrl` field value from a working mirror; tag an existing one via PUT `/indexer/{id}` with `tags:[1]`.

**History** — migrated dsfitz→t480 on 2026-06-23 (config dirs tar-streamed via root docker container; MediaCover/logs/Backups excluded — they regenerate). Old dsfitz containers removed; old config dirs left at `/volume2/docker/{sonarr,radarr,prowlarr}` as backup; compose backup at `/volume2/docker/docker-compose.yml.bak-arrmigration-2026-06-23`.

**Resolved 2026-06-24** — the old "Lidarr has no music indexer" issue (dead BitSearch) is fixed: BitSearch removed, and **1337x's Audio category now serves Lidarr's music searches** (it auto-syncs to Lidarr like the others).
