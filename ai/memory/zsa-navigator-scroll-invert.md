---
name: zsa-navigator-scroll-invert
description: ZSA Navigator trackball enumerates as zsa-technology-labs-voyager-1; scroll inversion is done in firmware (Oryx), NOT in hypr/input.lua
metadata:
  type: project
---

The ZSA Navigator trackball attaches to the Voyager, so Hyprland sees it as the
Voyager's pointer device `zsa-technology-labs-voyager-1` — not as a separate
trackball.

**Scroll inversion is handled in firmware via Oryx** as of 2026-10-08. The
previous OS-level `hl.device({ name = "zsa-technology-labs-voyager-1",
natural_scroll = true })` line was removed from `~/.config/hypr/input.lua` —
don't re-add it, or the two inversions cancel out.

**Why:** Pjf wants natural scrolling on the trackball only; the MX Master stays
traditional. Doing it in firmware makes it travel with the keyboard across
machines instead of needing per-host Hyprland config.

**How to apply:** For other Voyager/Navigator pointer tweaks that firmware can't
do (sensitivity, `scroll_factor`), target that same device name in
`input.lua`, not the keyboard entries (`zsa-technology-labs-voyager`,
`-keyboard`, `-consumer-control`). Related: [[zsa-voyager-udev-omarchy]],
[[kanata-home-row-mods]].
