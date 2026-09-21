---
name: via-hidraw-udev-omarchy
description: VIA/usevia.app on Omarchy needs a hidraw udev rule with GROUP="input" — uaccess ACLs don't land
metadata:
  type: project
---

On omarchy-1, usevia.app (Chrome WebHID) could not open the Altair-X keyboard
(vid `0xA103`, pid `0x0023`): `NotAllowedError: Failed to open the device`,
followed by `Received invalid protocol version from device`. Both are one fault —
`/dev/hidraw*` ships `0600 root:root` with no VIA/QMK udev rule, so the protocol
probe just gets silence and VIA misreports it as wrong firmware.

Fix at `/etc/udev/rules.d/92-via.rules` (2026-09-17):

```
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="a103", MODE="0660", GROUP="input", TAG+="uaccess"
```

**Why:** the stock VIA rule uses `GROUP="users"` plus `TAG+="uaccess"`. Neither
works here — pjf is in `pjf input wheel uinput`, not `users`, and the `uaccess`
ACL never appeared on the device despite session 2 being active/wayland on seat0
with the `uaccess` tag set. `GROUP="input"` sidesteps logind entirely.

**How to apply:** for any new VIA/QMK board, add its vid to the same rule with
`GROUP="input"`, reload (`udevadm control --reload-rules && udevadm trigger
--subsystem-match=hidraw --action=add`), and fully quit Chrome — WebHID caches
the failed permission. The VIA endpoint is the hidraw node whose
`report_descriptor` starts `06 60 ff 09 61` (usage page 0xFF60); a board exposes
several nodes and only that one answers. Firefox has no WebHID at all.

Mod-tap isn't a first-class VIA control: select the key, **Special → Any**, and
type `LCTL_T(KC_A)` literally. Moving home row mods into firmware would collide
with [[kanata-home-row-mods]] — disable the kanata layer for this board first.

Full write-up: `~/pkm/Altair-X mod-taps and VIA on Omarchy.md` — covers the udev
fix, VIA long-form keycode syntax, mod-tap timing, and Callum mods.
