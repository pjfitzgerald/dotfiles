---
name: t480-server
description: "t480 home server — Ubuntu 25.10, LUKS root, Comet Pro KVM attached, kdump boot-hang fix (2026-07-09), SSH access details"
metadata: 
  node_type: memory
  type: reference
  originSessionId: f497f25e-b628-4256-b744-ab68f3fc5aad
---

ThinkPad T480 home server ("t480", Tailscale 100.113.63.44, LAN 192.168.8.228). Runs [[karakeep-t480]].

- Ubuntu 25.10 (questing) desktop w/ GDM; systemd 257; **dracut** initramfs (not initramfs-tools).
- LUKS-encrypted root: single crypttab volume `dm_crypt-0` (nvme0n1p3 → LVM ubuntu-vg/ubuntu-lv). **TPM2 auto-unlock enabled 2026-07-09** (`systemd-cryptenroll`, PCR7, slot 1; passphrase slot 0 kept as fallback; needed `tpm2-tools` for dracut's tpm2-tss module). Unattended reboots verified working. Full runbook: `~/pkm/t480 boot hang & LUKS TPM auto-unlock.md`.
- GL.iNet **Comet Pro KVM** attached (hostname `glkvm`, 192.168.8.203, on tailnet). Shows as a second HDMI monitor to GNOME (extend by default); early-boot console renders on internal panel only.
- **2026-07-09 boot hang**: first reboot after 45 days uptime hung silently after `sockets.target` — `kdump-tools.service` start job blocked everything (triggered by that evening's unattended upgrade of initramfs-tools/crash/linux-firmware). Fixed by `systemctl cancel <job>` from `systemd.debug-shell=1` tty9, then `systemctl disable kdump-tools`. Debug recipe that worked: GRUB `e` → drop `quiet splash`, add `systemd.debug-shell=1` (tty9 via Comet virtual keyboard — physical F-keys unreliable) or `init=/bin/bash` for a pre-systemd root shell.
- SSH: `ssh t480` (user `pjf`, key auth). **No NOPASSWD sudo** (sudo-rs, interactive only) — privileged commands must be run by PJF.
