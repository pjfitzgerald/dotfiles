---
name: immich-go-dsfitz
description: "How to upload photos to PJF's Immich via immich-go on the dsfitz NAS (binary path, server/key, folder-as-album, SSH gotchas)"
metadata: 
  node_type: memory
  type: project
  originSessionId: af5e7287-b436-481a-811e-31f1de0ab580
---

immich-go (v0.27.0) is used to bulk-upload NAS folders into PJF's self-hosted Immich. Run it on the **dsfitz** Synology NAS (`ssh dsfitz`, Tailscale).

- **Binary:** `/volume2/shared-folder1/downloads/immich-go` (not on PATH)
- **Server:** `http://127.0.0.1:2283` on the NAS; **also reachable from other Tailscale nodes at `http://dsfitz:2283`** (verified 2026-07-01 from PJF's MacBook — so immich-go can run on the Mac and upload directly, no NAS copy needed).
- **API key:** `2dMc3KHyt3h1FWpzIWmoaGcIEorrV1vIOi3wPjIy11E`
- **Logs:** `/var/services/homes/patrick_admin/.cache/immich-go/*.log` — the **log is the source of truth**, not stdout.

Typical upload, folders-as-albums by full relative path:
```
/volume2/shared-folder1/downloads/immich-go upload from-folder --no-ui \
  --on-server-errors=continue \
  --server=http://127.0.0.1:2283 --api-key=<key> \
  --folder-as-album=PATH --album-path-joiner=" / " \
  "/path/to/folder"
```
`--folder-as-album=FOLDER` names albums by leaf folder; `=PATH` joins the path with `--album-path-joiner`. Simple single-album: `--into-album="Name"`.

Gotchas (learned the hard way):
- The "Uploaded 0" in stdout over SSH is a **no-GUI progress-counter artifact** — check the log file for real counts (`uploaded`, `upload error`, `server has same asset`).
- immich-go exits non-zero (exit 1) if even **one** file fails; doesn't mean the run failed overall.
- Re-running is **safe** — checksum dedupe skips already-uploaded assets ("server has same asset") and only retries failures.
- Launch long runs **detached** (`nohup … > /tmp/out 2>&1 &`) so an SSH drop (exit 255) doesn't kill the job. dsfitz gets very slow (load 90+) right after a big upload while Immich processes thumbnails/ML.
- For Epson FastFoto scans there's a `--manage-epson-fastfoto` flag (multiple files per photo).

Gotchas (immich-go quirks, learned 2026-07-01):
- **`file duplicated in the input` in the summary is NOT reliable** — immich-go over-groups (esp. Live Photo HEIC+MOV pairs) and marks unique files as internal dupes, skipping them without upload. On an iPhone Camera Roll it falsely flagged 2,771/5,731; only ~6 were true byte-dupes. Most flagged files WERE already on the server, but a handful of genuinely-unique ones got silently skipped. Isolating them in their own folder does NOT help — immich-go still refuses.
- **Definitive presence check = Immich's own API, not the immich-go summary.** `POST /api/assets/bulk-upload-check` with `{"assets":[{"id":<any>,"checksum":<base64 raw SHA-1>}]}` → per file `action: reject/duplicate` (present) or `accept` (missing). Batch 500/req. This is exactly how Immich dedupes, so it's ground truth. Hash local files with SHA-1, base64 the raw digest.
- **To force-upload files immich-go won't take:** upload straight via `POST /api/assets` (multipart: `assetData`, `deviceAssetId`, `deviceId`, `fileCreatedAt`/`fileModifiedAt` ISO from exiftool `-DateTimeOriginal`), then `PUT /api/albums/{id}/assets` `{"ids":[...]}` to add to an album.

History:
- 2026-06-02 uploaded "/volume2/shared-folder1/pictures/FastFoto Scans" — 25,218 unique assets, albums by path.
- 2026-07-01 migrated PJF's Mac Photos library (osxphotos export, 4,310 assets) and his encrypted iPhone backup Camera Roll (extracted via `iphone_backup_decrypt`, 5,731 files) into Immich from the MacBook over Tailscale. Full bulk-upload-check reconciliation confirmed 100% present; 3 stragglers (Live Photo HEICs immich-go skipped) pushed via the API. iPhone set is in album "iPhone Backup 2026-06-05".
- 2026-07-08 migrated PJF's two encrypted iPad local backups (iPad Mini 292, iPad Pro 292) into Immich the same way, via `iphone_backup_decrypt` + immich-go from the Mac. Albums "iPad Mini Backup 2026-07-04" / "iPad Pro Backup 2026-07-04". Both fully reconciled 0-missing via bulk-upload-check.
- 2026-07-08 (same session) re-verified the 2026-07-01 Mac Photos library migration by hashing the actual `originals/` folder inside the library package (`~/Pictures/misc/Photos Library.photoslibrary`, non-default location, iCloud Photos disabled for this account so no live-sync entanglement) and re-running bulk-upload-check directly against it — no need for a fresh osxphotos export. Of 5,697 files, 202 came back "missing," but every one was a `.AAE` edit-sidecar (Immich doesn't store these); all 5,495 real photo/video files were confirmed present. On that basis PJF had the library moved to `~/.Trash` (not yet emptied — 27GB not reclaimed until Trash is emptied).

**iPad-specific gotcha: `MatchFiles.CAMERA_ROLL` (Media/DCIM) is near-empty on modern iPads with iCloud Photos enabled** — only ~20 files vs 26k+ total CameraRollDomain files. The real photo library lives at `Media/PhotoData/CPLAssets/group%/%.%` (`MatchFiles.ICLOUD_PHOTOS`), which held 5,749 / 5,762 real assets for these two iPads. Always check both patterns via a manifest domain-count query (`backup.manifest_db_cursor()`, group by domain, then count DCIM vs CPLAssets matches) before assuming CAMERA_ROLL is the right extractor — don't just default to what worked for the iPhone. Verified CPLAssets output is full-resolution (4032×3024 HEICs), not thumbnails. Strip `.AAE` sidecar files (edit metadata, not media) from the extracted folder before uploading.

**Password handling for `iphone_backup_decrypt`:** to avoid pasting the encrypted-backup passphrase into the chat transcript, write it to a throwaway `chmod 600` file in the scratchpad (PJF pastes it there via his own text editor, outside the conversation), then have the Python extraction script read the file directly (`open(pw_file).read().strip()`) and pass it straight to `EncryptedBackup(passphrase=...)`. Never echo the password in Bash output/commands; delete the file immediately after extraction finishes.

**immich-go quirk (new): transient `io: read/write on closed pipe` upload errors** — a handful of files (3-8 out of ~5,500) failed with this on each run even though `curl` to `/api/server/ping` was healthy throughout. Simply re-running immich-go (idempotent, checksum dedupe) resolved most of them over 2-3 retries; the rest turned out to already be present on the server per the bulk-upload-check reconciliation (likely Live Photo HEIC/MOV checksum matches). Don't chase this error further than a couple of retries — go straight to the bulk-upload-check reconciliation for ground truth instead of trusting immich-go's own error count.
See [[immich]].
