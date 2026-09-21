# Memory

> General (non-client-specific) memories, synced via dotfiles for portability across machines.
> Machine/work-specific entries (e.g. Zscaler proxy setup, WebEOC knowledge) live only in the
> live memory dir on the work machine and are intentionally not tracked here.

## Feedback
- [feedback_no_coauthor.md](feedback_no_coauthor.md) — Never add Co-Authored-By lines to commit messages
- [feedback_no_credential_copying.md](feedback_no_credential_copying.md) — Never copy an API key from one tool's store into another without asking first

## Projects
- [project_pkm_sync.md](project_pkm_sync.md) — PKM syncs via Syncthing (folder ID ztety-fltwy) + git; .git excluded from Syncthing
- [project_homelab.md](project_homelab.md) — selfhosting inventory: dsfitz NAS (storage, RAM-constrained) + t480 (always-on compute); app-on-t480/data-on-NAS-via-NFS pattern
- [project_nextcloud.md](project_nextcloud.md) — Nextcloud runs on t480 w/ data on dsfitz via NFS; dsfitz is RAM-constrained (3.8 GB)
- [project_paperless.md](project_paperless.md) — Paperless migrated to t480 (OCR/SQLite) w/ documents on dsfitz via NFS; old dsfitz container left stopped
- [project_arr.md](project_arr.md) — *arr stack: Prowlarr/Sonarr/Radarr/Lidarr on t480, qBittorrent+Plex on dsfitz, /data shared via NFS; migrated 2026-06-23
- [project_freshrss.md](project_freshrss.md) — FreshRSS migrated to t480 2026-06-27, fully local SQLite (no NFS), port 8085; old dsfitz container stopped
- [project_memos.md](project_memos.md) — Memos note service set up fresh on t480 2026-06-28, fully local SQLite (no NFS), port 5230
- [project_audiobookshelf.md](project_audiobookshelf.md) — Audiobookshelf on t480 (config/DB local) with audio on dsfitz /volume2/data over NFS
- [project_calibre.md](project_calibre.md) — Calibre-Web-Automated on dsfitz: swap-thrash failure modes + s6-rc recovery without full container restart
- [t480-server.md](t480-server.md) — t480 home server: Ubuntu 25.10, LUKS root, Comet Pro KVM, kdump boot-hang fix + debug recipe, SSH/sudo details
- [karakeep-t480.md](karakeep-t480.md) — bookmark stack moved off dsfitz to t480; compose dir, Tailscale node, management, rollback
- [jellyfin-dsfitz.md](jellyfin-dsfitz.md) — Jellyfin runs on **t480** (`~/jellyfin`), not dsfitz; libraries, and the NAS `0700` dir-permission gotcha that silently hides media
- [immich-go-dsfitz.md](immich-go-dsfitz.md) — upload NAS folders to Immich via immich-go on dsfitz: binary path, server/key, folder-as-album, SSH gotchas

## References
- [reference_obsidian_vault.md](reference_obsidian_vault.md) — Obsidian vault access via symlink at ~/obsidian-vault (use Read/Write tools, not MCP)
- [reference_obsidian_claude_moc.md](reference_obsidian_claude_moc.md) — Claude-related notes live in zettelkasten/, organized via the claude-obsidian MOC note (no folder)
- [reference_dsfitz.md](reference_dsfitz.md) — dsfitz Synology NAS: SSH alias, /volume2/docker layout, tailnet, docker-compose v1, PUID 1026/100

## Omarchy (Linux/Hyprland)
- [syncthing-pkm-mesh.md](syncthing-pkm-mesh.md) — Syncthing setup syncing ~/pkm across omarchy, t480, pixel9a, mbp (folder id ztety-fltwy)
- [omarchy-ssh-no-agent.md](omarchy-ssh-no-agent.md) — no ssh-agent in the Hyprland session; passphraseless key, plain ssh works
- [hyprsunset-nightlight-schedule.md](hyprsunset-nightlight-schedule.md) — Omarchy night light = hyprsunset; schedule via time profiles in hyprsunset.conf + autostart; toggle is racy
- [studio-display-omarchy-color.md](studio-display-omarchy-color.md) — Studio Display on Omarchy (AMD): deliberately on default sRGB (not cm=wide); HDR impossible per EDID, sdr* knobs inert
- [inbound-ssh-tailnet.md](inbound-ssh-tailnet.md) — sshd keys-only + service exposure fixes on omarchy-1/t480; write-up in ~/pkm/SSH access across the tailnet.md
- [via-hidraw-udev-omarchy.md](via-hidraw-udev-omarchy.md) — /etc/udev/rules.d/92-via.rules needs GROUP="input"; uaccess ACLs don't land
- [kanata-home-row-mods.md](kanata-home-row-mods.md) — kanata user service on Omarchy; config at ~/.config/kanata/config.kbd, SUPER+F1 toggle; write-up in ~/pkm/zettelkasten/Home row mods on Omarchy.md
- [btrfs-no-home-snapshots.md](btrfs-no-home-snapshots.md) — snapper covers / only; all subvols share one fs, so undelete needs a live USB
- [zsa-voyager-udev-omarchy.md](zsa-voyager-udev-omarchy.md) — ZSA Voyager flashing on Omarchy: /etc/udev/rules.d/50-zsa.rules needs GROUP="input", not plugdev
- [zsa-navigator-scroll-invert.md](zsa-navigator-scroll-invert.md) — ZSA Navigator trackball scroll inverted per-device in hypr/input.lua
