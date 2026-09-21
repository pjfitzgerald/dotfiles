---
name: inbound-ssh-tailnet
description: "SSH and service exposure setup across the user's tailnet (omarchy-1, t480) and where it's documented"
metadata:
  type: project
---

As of 2026-09-03, both boxes on tailnet `astrapia-degree.ts.net` run classic `sshd`, keys-only:

- **omarchy-1** (`100.86.207.120`) — set up via `omarchy setup security sshd`; ufw `limit 22` still open to all sources (tailnet-only tightening was considered and **deliberately skipped**).
- **t480** (`100.113.63.44`) — password auth disabled and ufw enabled 2026-09-03. ~17 Docker services were rebound from `0.0.0.0` to `127.0.0.1` + tailnet IP, because ==Docker's iptables rules bypass ufw entirely==.

Router `gl-mt6000` verified to have no inbound path (no DNAT/UPnP, no wan TCP accepted on IPv6).

Tailscale SSH is deliberately **off** on both — it fights sshd for port 22 on tailnet IPs and causes host-key mismatches.

Full write-up: `~/pkm/SSH access across the tailnet.md`. Helper scripts live beside it in `~/pkm/`.

**Why:** The user asked for this documented rather than re-derived; it spans several machines, and two traps cost real time — the omarchy setup script leaves password auth ON if you cancel at its key prompt, and `systemctl is-active ufw` reports active even when ufw is disabled.

**How to apply:** Read the PKM note before changing SSH, firewall, or container port bindings on either box, and update it alongside any change. Connect as `omarchy-1` — the bare name `omarchy` is a stale tailnet node. Related: [[omarchy-ssh-no-agent]], [[syncthing-pkm-mesh]].
