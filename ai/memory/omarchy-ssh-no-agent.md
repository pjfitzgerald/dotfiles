---
name: omarchy-ssh-no-agent
description: "No SSH agent runs by default in the user's Omarchy/Hyprland session"
metadata: 
  node_type: memory
  type: reference
  originSessionId: f0f3b34b-1cf0-4223-a19c-c4a7b542d6dd
  modified: 2026-09-01T22:30:24.586Z
---

On the user's `omarchy` box, `SSH_AUTH_SOCK` is unset and no ssh-agent runs — the Hyprland session doesn't start one (unlike GNOME/KDE keyring). `ssh-agent.service` is `indirect`, `ssh-agent.socket` is `disabled`.

The default key `~/.ssh/id_ed25519` has **no passphrase**, so plain `ssh` works fine reading it off disk. `ssh-add -l` fails with "Could not open a connection to your authentication agent" — expected, not a bug.

To enable an agent: `systemctl --user enable --now ssh-agent.socket` then `export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"` in shell profile.

**How to apply:** Don't try to `ssh-add` or rely on agent forwarding on this box without setting the agent up first. Batch/non-interactive `ssh` with `BatchMode=yes` still works via the on-disk key. Related: [[syncthing-pkm-mesh]].
