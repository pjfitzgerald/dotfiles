# Memory

> General (non-client-specific) memories, synced via dotfiles for portability across machines.
> Machine/work-specific entries (e.g. Zscaler proxy setup, WebEOC knowledge) live only in the
> live memory dir on the work machine and are intentionally not tracked here.

## Feedback
- [feedback_no_coauthor.md](feedback_no_coauthor.md) — Never add Co-Authored-By lines to commit messages

## Projects
- [project_pkm_sync.md](project_pkm_sync.md) — PKM syncs via Syncthing (folder ID ztety-fltwy) + git; .git excluded from Syncthing
- [project_homelab.md](project_homelab.md) — selfhosting inventory: dsfitz NAS (storage, RAM-constrained) + t480 (always-on compute); app-on-t480/data-on-NAS-via-NFS pattern
- [project_nextcloud.md](project_nextcloud.md) — runs on t480 w/ data on dsfitz via NFS; dsfitz is RAM-constrained (3.8 GB)
- [project_paperless.md](project_paperless.md) — migrated to t480 (OCR/SQLite) w/ documents on dsfitz via NFS; old dsfitz container left stopped
- [project_arr.md](project_arr.md) — Prowlarr/Sonarr/Radarr/Lidarr on t480, qBittorrent+Plex on dsfitz, /data shared via NFS; migrated 2026-06-23
- [project_freshrss.md](project_freshrss.md) — migrated to t480 2026-06-27, fully local SQLite (no NFS), port 8085; old dsfitz container stopped
- [project_memos.md](project_memos.md) — note/memo service set up fresh on t480 2026-06-28, fully local SQLite (no NFS), port 5230
- [project_audiobookshelf.md](project_audiobookshelf.md) — Audiobookshelf on t480 (config/DB local) with audio on dsfitz /volume2/data over NFS
- [t480-server.md](t480-server.md) — t480 home server: Ubuntu 25.10, LUKS root, Comet Pro KVM, kdump boot-hang fix + debug recipe, SSH/sudo details
- [karakeep-t480.md](karakeep-t480.md) — bookmark stack moved off dsfitz to t480; compose dir, Tailscale node, management, rollback
- [jellyfin-dsfitz.md](jellyfin-dsfitz.md) — Jellyfin on dsfitz, now primary media player (Plex kept as backup): admin login, libraries, ports, compose
- [immich-go-dsfitz.md](immich-go-dsfitz.md) — upload NAS folders to Immich via immich-go on dsfitz: binary path, server/key, folder-as-album, SSH gotchas

## References
- [reference_obsidian_vault.md](reference_obsidian_vault.md) — Obsidian vault access via symlink at ~/obsidian-vault (use Read/Write tools, not MCP)
- [reference_obsidian_claude_moc.md](reference_obsidian_claude_moc.md) — Claude-related notes live in zettelkasten/, organized via the claude-obsidian MOC note (no folder)
- [reference_dsfitz.md](reference_dsfitz.md) — dsfitz Synology NAS: SSH alias, /volume2/docker layout, tailnet, docker-compose v1, PUID 1026/100
