---
name: project-homelab
description: Self-hosted homelab inventory + architecture — dsfitz NAS (storage) + t480 (compute), NFS split
metadata:
  node_type: memory
  type: project
  originSessionId: a0bf2c90-0a99-488d-a35a-1d97d65eb238
---

PJF runs a two-node self-hosted homelab. Read this first when asked about the selfhosting setup/config, then the per-service files. **Verify live state, don't assume** — `docker ps` on t480 and `ssh dsfitz 'sudo /usr/local/bin/docker ps'` on the NAS (sudo is passwordless for docker only).

- **dsfitz** — Synology **DS1821+** (Ryzen V1500B 8-thread), kernel 4.4, reached via Tailscale + LAN **192.168.8.184**. The **storage/RAID + backup** node. **RAM-constrained: only 3.8 GB**, runs ~21 containers (Plex, Jellyfin, Immich + ML, Nextcloud-DB-on-NAS-data, full *arr stack, qBittorrent, Calibre, FreshRSS, lubelogger, …) and chronically swap-thrashes. **Don't add heavy stacks here.** Docker via `/usr/local/bin/docker` (Container Manager). Data under `/volume2/docker/<service>` and `/volume2/shared-folder1`.
- **t480** — ThinkPad, **always-on server** (treat it as a server, not a laptop), 8 cores / **22 GB RAM**, Ubuntu. The **compute** node for RAM/CPU-hungry services. LAN **192.168.8.228**, tailnet `t480.astrapia-degree.ts.net`.

**Architecture pattern** (used by Nextcloud, Paperless, Immich): run the app + its DB on **t480's local SSD**, keep bulk data on **dsfitz over NFS** via Docker `local`-driver NFS volumes (`type: nfs`, `addr=192.168.8.184`, `nfsvers=3`) so the container fails fast if the NAS is down. SQLite/DB stays local (never on NFS). Compose stacks live in `~/docker/<service>/` (secrets in `.env`, mode 600). NFS exports configured in DSM per shared folder, scoped to t480's IP.

Per-service memory: [[project_nextcloud]], [[project_paperless]]. Full write-ups in `~/pkm/zettelkasten/` (the `[[selfhosted]]` hub, `[[t480]]`, `[[dsfitz]]`, `[[t480 ops tooling]]`, and `*setup*.md` notes). Open root-cause idea: add RAM to the DS1821+ (takes up to 32 GB ECC) to relieve the swap thrashing affecting every dsfitz service.
