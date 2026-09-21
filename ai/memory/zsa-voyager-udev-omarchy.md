---
name: zsa-voyager-udev-omarchy
description: ZSA Voyager flashing on Omarchy uses /etc/udev/rules.d/50-zsa.rules with GROUP="input", not plugdev
metadata:
  type: project
---

Installed 2026-09-21. ZSA's official Oryx/Wally udev instructions need adjusting for Arch/Omarchy:
`plugdev` does not exist and is not needed, there is no snap (skip `snap connect chromium:raw-usb`),
and no reboot is required — `udevadm control --reload` plus a replug is enough.

`/etc/udev/rules.d/50-zsa.rules` holds a Voyager-only, tightened version (0660 root:input rather than
ZSA's world-writable 0666):

    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3297", MODE="0660", GROUP="input"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="3297", MODE="0660", GROUP="input", SYMLINK+="ignition_dfu"

Rules for 16c0 / feed / 0483 (Ergodox EZ, Planck EZ, Moonlander) were dropped — those boards aren't owned.
Same GROUP="input" workaround as [[via-hidraw-udev-omarchy]], for the same reason: uaccess ACLs don't land
in the Hyprland session. Oryx needs WebUSB/WebHID, so flash from Chromium or Chrome — Firefox cannot work.

**Why:** ZSA's docs assume a Debian/Ubuntu layout; following them verbatim creates a stray group and
still leaves the bootloader node as root:root 0664.

**How to apply:** if flashing breaks after a firmware or udev update, check that the Voyager's
/dev/bus/usb node and its hidraw nodes are root:input 0660, and that /dev/ignition_dfu resolves.
