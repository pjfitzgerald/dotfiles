---
name: omarchy-1-minipc
description: omarchy-1 is a mostly-always-on Beelink SER8 mini PC (not a laptop) and can host services itself
metadata: 
  node_type: memory
  type: project
  originSessionId: 16915b61-399f-41bb-8fc0-588158147a10
  modified: 2026-10-22T12:06:35.265Z
---

`omarchy` / tailnet `omarchy-1` is a **Beelink SER8 mini PC** — Ryzen 7 8745HS,
16 cores, 11 GiB RAM, no battery, chassis reports `desktop`. It is **mostly
always on** (observed uptime 6+ weeks), so it is a viable host for services, not
just a dev workstation.

- Tailnet: `100.86.207.120` (MagicDNS name `omarchy-1` resolves)
- LAN: `192.168.8.199` over `wlp2s0`
- Docker is installed and was idle as of 2026-10-22

**Why:** PJF corrected me on 2026-10-22 after I described it as a laptop and
warned that a service running on it would die when the box slept. It does not
sleep. Do not raise battery/suspend concerns for this machine, same as [[t480-server]].

**How to apply:** treat omarchy-1 as a second always-on node alongside t480 when
choosing where to run something. Dev builds of PJF's own projects live here; see
[[safe-technologies-site]]. [[project_homelab]] describes dsfitz + t480 only and
predates this.
