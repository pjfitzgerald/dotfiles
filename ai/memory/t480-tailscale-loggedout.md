---
name: t480-tailscale-loggedout
description: t480 was logged out of Tailscale as of 2026-10-26; reach it on the LAN at 192.168.8.228
metadata:
  type: project
---

As of 2026-10-26 the t480 reports `Logged out.` from `tailscale status`
(tailscaled is running and `tailscale0` still holds 100.113.63.44, but the
node is off the tailnet). Everything tailnet-only on that box — inventory
staging, Jellyfin, Nextcloud, Paperless, Karakeep, Gitea — is unreachable
from other devices until someone runs `sudo tailscale up` on it.

**Why:** it looks exactly like the host being down — `ping 100.113.63.44`
fails and `ssh t480` times out — so it is easy to conclude the t480 is off.

**How to apply:** reach it over the LAN instead: `ssh pjf@192.168.8.228`
(ICMP is blocked there, so a failed ping means nothing). Re-check with
`ssh pjf@192.168.8.228 tailscale status` before assuming the box is down.
Related: [[t480-server]], [[inventory-cli-hermes]].
