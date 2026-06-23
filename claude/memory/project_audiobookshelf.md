---
name: project-audiobookshelf
description: Audiobookshelf runs on t480 (config/DB local) with audio on dsfitz /volume2/data over NFS
metadata:
  node_type: memory
  type: project
---

Audiobookshelf (set up 2026-06-23) runs as a Docker stack on **t480**, reached at `http://t480.astrapia-degree.ts.net:13378` (port 13378→80; t480 is on the tailnet so it's accessible over Tailscale with no sidecar). Compose at `~/docker/audiobookshelf/`. Same app-on-t480/data-on-NAS pattern as [[project_paperless]] / [[project_nextcloud]].

- **Config + metadata on t480 local SSD** (`~/docker/audiobookshelf/{config,metadata}`). The **SQLite DB lives in config — never put it on NFS** (locking/corruption), same lesson as paperless.
- **Audio on dsfitz in the shared media tree `/volume2/data`** (RAID + Hyper Backup), mounted as Docker `local`-driver **NFS volumes** (addr 192.168.8.184, nfsv3, rw,hard,noatime,nolock): `:/volume2/data/audiobooks` → `/audiobooks`, `:/volume2/data/podcasts` → `/podcasts`. Audiobooks library starts empty; the existing ~297 GB `/volume2/shared-folder1/podcasts` collection was moved into `/volume2/data/podcasts`.

Key decisions/gotchas:
- The user wanted audio in the **existing media tree `/volume2/data`**, not a service-specific dir. A *separate Synology share over the same bytes is not possible* (shared folders can't overlap; NFS export perms are keyed per client IP, so the same host can't be ro+rw on one export). Solution: the **`/volume2/data` NFS export was flipped from ro to rw for t480** (DSM), and **ABS mounts only the two subdirs** (`audiobooks`, `podcasts`), so it can't see/touch the rest of the media tree (movies/tv/music) even though the export is folder-level rw.
- **Jellyfin is unaffected** — it stays read-only because it mounts `/mnt/dsfitz-data/media:ro` (host fstab `ro` + container `:ro`), regardless of the export now being rw.
- Export squash is **"No mapping" (no_root_squash)** — same as the `/volume2/docker` export; ABS runs as root so NFS files land root-owned, fine for a container path.
- ABS image (`ghcr.io/advplyr/audiobookshelf`) has **no curl** — healthcheck uses `wget -q -O /dev/null http://localhost:80/healthcheck`. Internal port is **80**, not 13378.
- Podcasts content is a mix of loose top-level mp3s and per-show subfolders; ABS expects one folder per podcast, so loose files may need tidying in the UI later.

**Next steps (logged 2026-06-23, not yet done):** (1) connect each moved podcast folder to its RSS feed in ABS (Edit → Feed URL → auto-download); source feed URLs from `gpodder-downloads/` subscription data or the NetNewsWire OPML. (2) Import audiobooks from [[calibre]]: 104 books tagged `audiobook` in `/volume2/data/books/calibre_library/` store the audio as a calibre **format** — usually ZIP (packed mp3s/m4b), sometimes direct M4A/M4B. Plan: query `metadata.db` (or `calibredb` inside the `calibre-web-automated` container) for tag=audiobook + audio formats, then unzip/copy each into `/volume2/data/audiobooks/<Author>/<Title>/` (run on dsfitz, disk-local) and let ABS scan. Full design in the pkm doc.

Full doc: `~/pkm/zettelkasten/audiobookshelf setup on t480.md`. Overview in [[project_homelab]].
