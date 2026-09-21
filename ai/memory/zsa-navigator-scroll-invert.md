---
name: zsa-navigator-scroll-invert
description: ZSA Navigator trackball enumerates as zsa-technology-labs-voyager-1; scroll inverted per-device in hypr/input.lua
metadata:
  type: project
---

The ZSA Navigator trackball attaches to the Voyager, so Hyprland sees it as the
Voyager's pointer device `zsa-technology-labs-voyager-1` — not as a separate
trackball. Per-device scroll inversion lives in `~/.config/hypr/input.lua`:
`hl.device({ name = "zsa-technology-labs-voyager-1", natural_scroll = true })`.

**Why:** Pjf wants natural scrolling on the trackball only; the MX Master stays
traditional. A global `input:natural_scroll` would flip both.

**How to apply:** For any other Voyager/Navigator pointer tweak (sensitivity,
scroll_factor), target that same device name, not the keyboard entries
(`zsa-technology-labs-voyager`, `-keyboard`, `-consumer-control`). Related:
[[zsa-voyager-udev-omarchy]], [[kanata-home-row-mods]].
