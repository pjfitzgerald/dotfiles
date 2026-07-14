---
name: jellyfin-dsfitz
description: "PJF's Jellyfin server on dsfitz — now the primary media player (Plex kept as backup). Admin login, libraries, ports, how it's deployed."
metadata: 
  node_type: memory
  type: project
  originSessionId: 47376f41-52fe-4bdc-b743-517d9f94b53b
---

Jellyfin (v10.11.8) is PJF's **primary** media player as of 2026-06-18, replacing Plex as primary. Plex is kept running as backup. Both run as Docker containers on the **dsfitz** Synology DS1821+ (`ssh dsfitz`, Tailscale), managed by Container Manager via `/volume2/docker/docker-compose.yml` (linuxserver images). The same compose has the *arr stack: sonarr/radarr/prowlarr/qbittorrent.

- **Jellyfin URL (LAN):** `http://dsfitz.local:8096` (or `http://127.0.0.1:8096` on the NAS). Remote = Tailscale address :8096.
- **Plex:** still up on port 32400 (host networking).
- **Admin user:** `pjf` / password `lLAdVeRFJGiiJMpWGlPChW` (generated 2026-06-18 — change in UI when convenient).
- **Config dir:** `/volume2/docker/jellyfin` → `/config`. DB at `data/data/jellyfin.db`.
- **Media:** `/volume2/data/media` mounted read-only at `/media`.
- **Docker control needs sudo password** (not available over SSH) — but the container was already running, so the whole setup was done via the Jellyfin **HTTP API** over SSH (startup wizard + `/Library/VirtualFolders`), no docker access needed.

Libraries (folder → type):
- Movies ← movies (movies)
- Shows ← tv + daily-wire (tvshows)
- Music ← music (music)
- Comedy ← comedy (movies)
- Documentaries ← documentaries (movies)
- Sport ← sport (homevideos)
- YouTube ← youtube (homevideos)
- Misc ← misc (homevideos)

Outstanding (client-side, on PJF): install Jellyfin apps on devices (Apple TV/phone/web) and point at the server. See [[immich-go-dsfitz]] for the same NAS/SSH setup.
