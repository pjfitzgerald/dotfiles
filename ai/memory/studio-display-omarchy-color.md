---
name: studio-display-omarchy-color
description: Apple Studio Display on Omarchy (AMD) — prefers uncorrected sRGB over cm=wide; HDR impossible per EDID
metadata: 
  node_type: memory
  type: project
  originSessionId: cf0342ae-b4c7-4dcb-93d7-076b85f3cdd0
  modified: 2026-09-02T11:42:19.874Z
---

Omarchy box (AMD HawkPoint iGPU), Apple Studio Display on **DP-3**. Colours looked
washed out vs the same display driven by macOS/Windows. Worked through 2026-09-02.

**Settled config** in `~/.config/hypr/monitors.lua`:
```lua
hl.monitor({ output = "DP-3", mode = "preferred", position = "auto", scale = omarchy_monitor_scale, bitdepth = 10 })
```
No `cm` key — i.e. Hyprland's default `srgb`. **This is a deliberate preference,
not an oversight.** Patrick A/B'd `srgb` against `cm = "wide"` and picked `srgb`:
it sends sRGB values to the panel's native P3 primaries unmapped, which
oversaturates and reads punchier. `cm = "wide"` is colorimetrically correct but
looks flatter. Don't "fix" this back to `wide` without asking.

**cm = "hdr" is impossible on this panel — established from the EDID**, not
inferred. `edid-decode /sys/class/drm/card1-DP-3/edid`:
- HDR Static Metadata Data Block lists exactly one EOTF: *Traditional gamma - SDR
  luminance range*. No SMPTE ST2084 (PQ), no HLG. Max luminance 603 cd/m².
  So `supportsHDR()` is false and `cm = "hdr"` silently falls back to `srgb`.
- `hyprctl systeminfo` showing `hdr ✔️` is the GPU/backend capability, NOT the panel's.
- Consequently `sdrbrightness` / `sdrsaturation` never do anything — their shader
  path (`SH_FEAT_SDR_MOD`, `ShaderLoader.hpp`) is gated on `SDR <-> HDR &&
  (sdrSaturation != 1 || sdrBrightnessMultiplier != 1)`. Values get stored and
  reported by `hyprctl monitors` while having zero pixel effect. Misleading.
- Colour Characteristics block *does* describe P3 primaries (R 0.6796,0.3203 /
  G 0.2646,0.6904 / B 0.1503,0.0595 / D65), but the **Colorimetry Data Block is
  empty**, which is why `cm = "auto"` resolves to `srgb` rather than `wide`.

Other findings:
- Night light had been stuck ON at 4000K, contributing to the washed-out look.
  See [[hyprsunset-nightlight-schedule]].
- Brightness was at 30%; raised via `omarchy brightness display apple 70%`
  (asdcontrol; no DDC/CI — `ddcutil` fails, I2C x37 unresponsive; NOPASSWD sudoers
  at `/etc/sudoers.d/50-asdcontrol`, device `/dev/usb/hiddev2`). It drifts on its
  own (reads 45 later) — the display's ambient light sensor. Unresolved.
- `bitdepth = 10` → `currentFormat` `XRGB8888` → `XRGB2101010`.
- Only remaining saturation dial would be `decoration:screen_shader` (custom GLSL).
  Offered, not pursued.

`hyprctl keyword monitor ...` is rejected ("can't work with non-legacy parsers")
because the config is Lua — edit the `.lua` and `hyprctl reload`.
