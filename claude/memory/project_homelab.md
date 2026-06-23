---
name: project-homelab
description: Self-hosted homelab inventory + architecture — dsfitz NAS (storage) + t480 (compute), NFS split
metadata:
  node_type: memory
  type: project
  originSessionId: a0bf2c90-0a99-488d-a35a-1d97d65eb238
---

PJF runs a two-node self-hosted homelab. Read this first when asked about the selfhosting setup/config, then the per-service files. **Verify live state, don't assume** — `docker ps` on t480 and `ssh dsfitz 'sudo /usr/local/bin/docker ps'` on the NAS (sudo is passwordless for docker only).

- **dsfitz** — Synology **DS1821+** (Ryzen V1500B 8-thread), kernel 4.4, reached via Tailscale + LAN **192.168.8.184**. The **storage/RAID + backup** node. **RAM-constrained: only 3.8 GB**, runs ~15 containers (Plex, Immich + ML, qBittorrent, Calibre-Web-Automated, FreshRSS, lubelogger, …) and chronically swap-thrashes. **The *arr apps (Prowlarr/Sonarr/Radarr/Lidarr) moved to t480 on 2026-06-23** — only **qBittorrent** (the download client) and **Plex** remain here from that stack; bulk media + downloads still live here under `/volume2/data`. **Don't add heavy stacks here.** Docker via `/usr/local/bin/docker` (Container Manager). Data under `/volume2/docker/<service>` and `/volume2/shared-folder1`.
- **t480** — ThinkPad, **always-on server** (treat it as a server, not a laptop), 8 cores / **22 GB RAM**, Ubuntu. The **compute** node for RAM/CPU-hungry services. LAN **192.168.8.228**, tailnet `t480.astrapia-degree.ts.net`. **It is NOT vulnerable to laptop problems — do not raise sleep / suspend / lid-close / battery / WiFi-dropout as reliability concerns.** It's configured to stay on permanently (lid-close is a no-op, suspend disabled). PJF has corrected this repeatedly; never suggest "disable suspend" or treat it as a flaky laptop again.

**Architecture pattern** (used by Nextcloud, Paperless, Immich, the *arr stack, Audiobookshelf): run the app + its DB on **t480's local SSD**, keep bulk data on **dsfitz over NFS** via Docker `local`-driver NFS volumes (`type: nfs`, `addr=192.168.8.184`, `nfsvers=3`) so the container fails fast if the NAS is down. SQLite/DB stays local (never on NFS). Compose stacks live in `~/docker/<service>/` (secrets in `.env`, mode 600). NFS exports configured in DSM per shared folder, scoped to t480's IP. **Gotcha:** an export can be `ro` and/or `all_squash` in DSM (reads succeed but writes fail with EROFS / blocked dirs) — for any app on t480 that must *write* to NAS storage, the DSM NFS rule for 192.168.8.228 needs **Read/Write + Squash "No mapping"** (the `/volume2/data` rule was fixed this way for the *arr migration so the container uid 1026 passes through as patrick_admin).

Per-service memory: [[project_nextcloud]], [[project_paperless]], [[project_arr]], [[project_audiobookshelf]]. Full write-ups in `~/pkm/zettelkasten/` (the `[[selfhosted]]` hub, `[[t480]]`, `[[dsfitz]]`, `[[t480 ops tooling]]`, and `*setup*.md` notes). Open root-cause idea: add RAM to the DS1821+ (takes up to 32 GB ECC) to relieve the swap thrashing affecting every dsfitz service.
