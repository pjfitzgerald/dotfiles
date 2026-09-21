---
name: btrfs-no-home-snapshots
description: Omarchy btrfs has snapper config for / only; /home is unprotected, and all subvols share one fs
metadata:
  type: project
---

On omarchy-1, `/`, `/home`, `/var/log` and `/var/cache/pacman/pkg` are subvolumes of a
single btrfs filesystem (UUID e393849a-96e6-428e-8b5a-1f0497ace7a7, LUKS on /dev/nvme0n1p2).
Snapper has a `root` config only — **there are no /home snapshots**. `fstrim.timer` is
disabled and no `discard` mount option is set, so deleted blocks survive on the NVMe.

**Why:** discovered 2026-09-20 while trying to recover a deleted Chrome profile. Because
every subvolume lives on one fs, the fs can never be unmounted from the running install,
and `btrfs restore` refuses to run on a mounted fs (it checks by fs UUID, so read-only
loop devices and `remount,ro` do not fool it). Offline recovery needs a live USB.

**How to apply:** treat ~/home as having no rollback safety net — suggest adding a snapper
`home` config. For any btrfs undelete here, go straight to a live USB plus
`btrfs-find-root` + `btrfs restore -t <bytenr> -r 257`; don't waste time on loop-device
workarounds. Never run fstrim before attempting recovery. Related: [[syncthing-pkm-mesh]].
