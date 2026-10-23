---
name: project-vimarchy
description: vimarchy — Homerow-style keyboard UI-element clicker for Omarchy/Hyprland; repo location and the platform facts that shape it
metadata:
  type: project
---

A Linux/Hyprland equivalent of macOS Homerow.app — hotkey, hint labels on clickable
elements, type the label to click. **Renamed from `homerow-omarchy` on 2026-10-23.**

- Repo: `~/code/projects/vimarchy` (git, scaffolded 2026-10-23)
- Hub note: `~/pkm/projects/01 active/vimarchy/vimarchy.md`
- In-repo docs are authoritative for platform detail: `docs/findings.md` (measured
  behaviour + dead ends), `docs/decisions.md`, `AGENTS.md` (traps).
- Python against the **system** python — PyGObject/Atspi/Gtk4LayerShell are system
  packages, deliberately not in `pyproject.toml`. No venv.

The two facts that shape everything, kept here because they are easy to "fix" wrongly:

- **AT-SPI `CoordType.SCREEN` extents are (0,0) for every element under Wayland.**
  `WINDOW` extents are correct. Global rect = `hyprctl clients` window origin +
  WINDOW extents.
- **The a11y bus ships disabled on Omarchy.** Enabled live via `busctl --user
  set-property org.a11y.Bus /org/a11y/bus org.a11y.Status IsEnabled b true` (+
  `ScreenReaderEnabled`, + `gsettings set org.gnome.desktop.interface
  toolkit-accessibility true`). **Not yet persisted across reboots.**

Pointer injection (solved 2026-10-23, no new packages): place the cursor with
`hyprctl dispatch 'hl.dsp.cursor.move({ x = .., y = .. })'` (absolute, <=4px error),
and click with a uinput device that declares `REL_X`/`REL_Y` but only emits `BTN_*`.
Do **not** retry uinput relative motion (pointer acceleration, ~2x over-travel),
`hyprctl keyword` accel patching (Lua config parser rejects it), or a uinput virtual
tablet (libinput never classifies it). `wlr-protocols` + a `zwlr_virtual_pointer_v1`
C helper was the old plan and is no longer needed.

Chrome/Chromium/Electron register on the bus with correctly-sized frames, but their
content tree never populates — grid-bisect fallback is mandatory for them, and for
terminals, which never have a tree.

Related: [[via-hidraw-udev-omarchy]], [[kanata-home-row-mods]], [[omarchy-1-minipc]]
