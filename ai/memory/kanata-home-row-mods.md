---
name: kanata-home-row-mods
description: "Home row mods via kanata on Omarchy — config, service, SUPER+F1 toggle, gotchas"
metadata: 
  node_type: memory
  type: project
  originSessionId: 1803e599-0b95-48da-9fb9-0739b426e797
  modified: 2026-09-06T06:10:31.939Z
---

Home row mods set up 2026-09-06 on the Omarchy desktop via kanata (AUR `kanata-bin`),
run as a systemd **user** service (`~/.config/systemd/user/kanata.service`).

- Layout config: `~/.config/kanata/config.kbd`. Outside-in holds: a/;=Shift, s/l=Ctrl,
  d/k=Alt, f/j=Super; Caps→Ctrl. "Advanced" style (`tap-hold-release-keys` + `nomods`
  layer + `concurrent-tap-hold yes`).
- Toggle: `~/.local/bin/kanata-toggle` (start/stop service + `omarchy notification send`),
  bound to **SUPER+F1** in `~/.config/hypr/bindings.lua`.
- No device pinning on purpose (`linux-device-detect-mode keyboard-only`,
  `linux-continue-if-no-devs-found yes`) so HHKB wired + Bluetooth + any other keyboard
  all work; kanata inotify-watches `/dev/input` for hotplug.
- Gotchas: HHKB device name differs BT vs USB (don't pin it); a bad config can lock the
  keyboard incl. the sudo prompt — recover by SSH from another box + `systemctl --user
  stop kanata.service` (needs XDG_RUNTIME_DIR + DBUS_SESSION_BUS_ADDRESS exports over SSH);
  panic kill chord is physical LeftCtrl+Space+Esc; group changes need full re-login.

Full write-up: `~/pkm/zettelkasten/Home row mods on Omarchy.md`. Related: [[omarchy-ssh-no-agent]],
[[inbound-ssh-tailnet]], [[syncthing-pkm-mesh]].
