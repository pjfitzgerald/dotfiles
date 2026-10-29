---
name: voyager-to-altair-port
description: Porting a ZSA Voyager Oryx layout onto the Altair-X — the keymap is extractable from the compiled .bin, via voyager-port-to-altair
metadata:
  type: project
---

A Voyager Oryx layout can be ported to the Altair-X **without the Oryx `_source`
zip** — the keymap is a flat little-endian uint16 array inside the compiled
`.bin` (84 slots/layer, 52 of them keys). `~/.local/bin/voyager-port-to-altair
<bin>` finds it and emits JSON for `altair-load-keymap`; siblings
`altair-dump-keymap` / `altair-load-keymap` read and write the board over raw HID.

**Why:** Oryx's download is firmware, not a layout file, and PJF often has only
the `.bin`. Flashing that `.bin` to the Altair is not the ask (different board) —
"flash the Voyager layout" means transplanting the keymap via VIA.

**How to apply:** dump the board to `~/Documents/altair_x.<date>-preport.json`
first — it's the rollback. Full write-up, geometry table and gotchas (7 layers
vs the Altair's 6; `0x7700-0x7FFF` keycodes can't cross) in
`~/pkm/Altair-X mod-taps and VIA on Omarchy.md`. See [[via-hidraw-udev-omarchy]].
