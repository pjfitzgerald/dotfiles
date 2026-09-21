---
name: hyprsunset-nightlight-schedule
description: Omarchy night light = hyprsunset; schedule via time profiles in hyprsunset.conf + autostart
metadata: 
  node_type: memory
  type: reference
  originSessionId: cf0342ae-b4c7-4dcb-93d7-076b85f3cdd0
  modified: 2026-09-02T11:16:50.630Z
---

Omarchy night light is `hyprsunset`. `omarchy toggle nightlight` is only a manual
on(4000K)/off(6500K) switch — and it's racy, sometimes not clearing; force with
`hyprctl hyprsunset temperature 6500 && hyprctl hyprsunset identity`.

To **schedule** it, edit `~/.config/hypr/hyprsunset.conf` (add `profile { time = HH:MM, temperature = N }`
blocks; keep the `07:00 / identity = true` block as the morning "off"), then add
`o.launch_on_start("hyprsunset")` to `~/.config/hypr/autostart.lua` so profiles
apply on boot. Apply with `omarchy restart hyprsunset`. hyprsunset only re-reads
profiles on restart or when crossing a profile time.

Related: [[studio-display-omarchy-color]] (a stuck 4000K night light was part of a
washed-out-colour complaint).
