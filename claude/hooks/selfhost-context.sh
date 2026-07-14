#!/usr/bin/env bash
# UserPromptSubmit hook: when a prompt is about PJF's self-hosted homelab,
# surface the authoritative memory notes so Claude reads them before answering.
# Stdout from a UserPromptSubmit hook is injected into the model's context.
#
# Wired up in claude/settings.json -> hooks.UserPromptSubmit.
# Symlinked to ~/.claude/hooks/ by install.sh.

input=$(cat)

# Service / infra keywords that signal a homelab question. Case-insensitive.
pattern='dsfitz|paperless|nextcloud|immich|jellyfin|\bplex\b|sonarr|radarr|prowlarr|qbittorrent|calibre|freshrss|lubelogger|karakeep|synology|home ?lab|self.?host|\bNAS\b|tailnet|astrapia-degree|t480 server|docker (stack|compose)|/volume2'

if printf '%s' "$input" | grep -qiE "$pattern"; then
  cat <<'EOF'
<self-hosting-context>
This prompt looks like it's about PJF's self-hosted homelab. Before answering,
read the authoritative notes (do not answer from memory of this blurb alone):
  ~/dotfiles/claude/memory/project_homelab.md    (inventory + architecture pattern)
  ~/dotfiles/claude/memory/project_paperless.md
  ~/dotfiles/claude/memory/project_nextcloud.md
  ~/pkm/zettelkasten/*setup*.md and the [[selfhosted]] / [[t480]] / [[dsfitz]] notes (full write-ups)

Verify live state, don't assume it matches the notes:
  - t480 services:  docker ps
  - dsfitz services: ssh dsfitz 'sudo /usr/local/bin/docker ps'   (sudo passwordless for docker only)

Quick facts: dsfitz = Synology DS1821+, RAM-constrained (3.8 GB) — don't add heavy
stacks there. t480 = always-on server (22 GB RAM) — home for RAM/CPU-hungry services,
with bulk data on dsfitz over NFS (Docker local-driver NFS volumes, LAN 192.168.8.184).
Compose stacks live in ~/docker/<service>/.
</self-hosting-context>
EOF
fi

exit 0
