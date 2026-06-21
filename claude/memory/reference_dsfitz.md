---
name: dsfitz Synology NAS
description: PJF's Synology NAS hostname, SSH access, and docker stack layout
type: reference
originSessionId: f1e6b7a3-205e-4b6e-943e-0db92e7e0c62
---
`dsfitz` is the SSH alias for PJF's Synology NAS. Reachable as `ssh dsfitz` from the Mac (configured in `~/.ssh/config`).

- Docker stacks live at `/volume2/docker/<service>/` — newer services follow per-folder compose pattern (paperless, karakeep, immich, calibre, etc.), older ones share `/volume2/docker/docker-compose.yml` (qbittorrent, sonarr, radarr, prowlarr, plex, jellyfin)
- Shared media/data root: `/volume2/data/` — `media/` for Plex/Jellyfin, `books/` for Calibre, etc.
- Docker version: older v1 — use `docker-compose` (hyphen), not `docker compose` (v2 plugin not installed). Full path: `/usr/local/bin/docker-compose`
- PUID/PGID convention: 1026/100 (matches `patrick_admin:users`)
- Tailnet: `astrapia-degree.ts.net` — services exposed at `<service>.astrapia-degree.ts.net` via Tailscale sidecar pattern (`tailscale/tailscale` image with `TS_USERSPACE=true`, app shares `network_mode: service:<sidecar>`). Tailscale Serve provides HTTPS-on-443 with auto-issued certs.
- Sudo requires interactive password — can't run `sudo` non-interactively over SSH; defer privileged commands to PJF.
