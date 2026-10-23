---
name: zsa-voyager-hrm-automouse
description: Voyager layout "hrm" — left Ctrl never fires because S is a tap dance with SINGLE_HOLD unhandled (confirmed by event trace); auto-mouse layer 4 also overrides A/D/F but was NOT the reported symptom
metadata:
  type: project
---

Analysed 2026-09-27. Oryx layout `hrm` (hashId 5LvQw, revision aNjOgD), read from Keymapp's cache
(`~/.config/.keymapp/keymapp.sqlite3`, table `revision`) and the Oryx-generated source zip.

**Confirmed cause** (90 s event trace of /dev/input/event3, 2026-09-27): zero `LCTRL` presses emitted in the
whole capture while `w` went out bare 8× in a row — i.e. left Ctrl+W does nothing. Every `s` press shows a
tell-tale 10.0 ms press->release, which is the `wait_ms(10)` in `dance_0_reset()`, proving `s` comes from the
tap dance and not from `MT()`. No layer-1 bleed and no layer-4 activation in the capture: PJF confirmed from
the board LEDs that the mouse layer is off when the failure happens, so defect 2 below is real but is NOT
the reported symptom.

Two defects, both left-hand only:

1. **`S` is `TD(DANCE_0)`, not `MT(MOD_LCTL, KC_S)`** — it was built via Oryx's "Tap-Hold" tab instead of
   the Hold tab. `dance_0_finished()` handles SINGLE_TAP / DOUBLE_TAP / DOUBLE_HOLD / DOUBLE_SINGLE_TAP
   but **not SINGLE_HOLD**, so plain hold-S emits nothing at all; Left Ctrl only fires on tap-then-hold.
2. **Auto-mouse layer 4** (`zsa/navigator_trackball` + `zsa/automouse`, `AUTOMOUSE_LAYER 4`,
   `AUTOMOUSE_THRESHOLD 10`, ~650 ms QMK default hold-open) overrides the *left* home row:
   A=`TO(0)`, D=`KC_MS_BTN2`, F=`KC_MS_BTN1`. The right home row is `KC_TRANSPARENT` there, so right-hand
   mods keep working — hence the asymmetric, intermittent symptom, correlated with trackball use.
   `QK_LLCK` also sits on layer 4 (left top row, T position) and can lock layer 4 indefinitely.

Contributing: no tap-hold tuning at all in the generated `config.h` — no `TAPPING_TERM` (QMK default 200 ms),
no `PERMISSIVE_HOLD` / `HOLD_ON_OTHER_KEY_PRESS` / `CHORDAL_HOLD` / `QUICK_TAP_TERM`, so fast same-hand
rolls resolve as letters. Holding Space (`MO(1)`) also masks the left home row by design.

kanata is NOT involved — the user service has been dead since 2026-09-13; home-row mods are firmware-side now.
See [[kanata-home-row-mods]], [[zsa-navigator-scroll-invert]], [[zsa-voyager-udev-omarchy]].

**Why:** the failure looks random but is fully explained by layer 4 activation, so tuning tapping terms
would have been wasted effort.

**How to apply:** fix in Oryx — rebuild S with the Hold tab (tap S / hold Left Ctrl), and make layer 4's
A/D/F transparent (move mouse buttons off the home row). Read the live layout any time with Keymapp running:
`sqlite3 ~/.config/.keymapp/keymapp.sqlite3 "select * from revision"`, and `kontroll status` for the active layer.
