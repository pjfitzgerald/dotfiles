---
name: project-calibre
description: Calibre-Web-Automated on dsfitz — swap-thrash failure modes + s6-rc recovery without full container restart
metadata:
  type: project
---

Calibre-Web-Automated (crocodilestick/calibre-web-automated, v4.0.6) runs on **dsfitz** with a Tailscale sidecar (`calibre-calibre-web-ts-1`, container shares its netns). Web app is `cps.py` on port 8083. See [[project-homelab]] for the box.

Three distinct "not loading" failure modes. The first two (2026-07) are downstream of dsfitz swap-thrashing; the third (2026-08-25) is an app bug and is **not** resource-related:

1. **App swapped out / wedged**: container "Up X weeks (unhealthy)", `cps.py` alive but RSS ≈ 0, health-check curls hang for days inside the container, HTTP times out. Fix: `docker restart calibre-web-automated`.
2. **Web service never starts after a restart under load**: CWA's `calibre-binaries-setup` s6 service runs a `calibredb --version` check that **times out under IO load and falsely concludes Calibre isn't installed**, then its 5-min re-download can also time out → service exits 1 → `svc-calibre-web-automated` never starts → connection refused on 8083. Fix without another restart roulette:
   `ssh dsfitz "sudo /usr/local/bin/docker exec calibre-web-automated bash -c 's6-rc -u change calibre-binaries-setup; s6-rc -u change svc-calibre-web-automated'"`
   (Calibre binaries persist at `/app/calibre`; the re-run usually succeeds and the web service comes up in seconds.)

3. **Duplicate-scan deadlock (app bug, v4.0.6)**: container "Up N minutes (unhealthy)" but `cps.py` has *normal* RSS, the box is idle (~0% CPU, 0% iowait, no swap pressure) — yet HTTP hangs. Port 8083 **is** listening, with a large `rx_queue` on the listen socket (connections accepted by the kernel, never by the app). Cause: CWA's duplicate scan ran with `duplicate_scan_frequency = 'after_import'`, so every web-UI upload fired a scan whose worker thread (`cps/tasks/duplicate_scan.py` → `cps/duplicates.py:find_duplicate_candidate_ids_sql`) deadlocks against a concurrent web request on `metadata.db`. Because the web server is **gevent** (single-threaded) and SQLite's C call doesn't yield to the hub, one blocked query freezes the *entire* server. Fixed 2026-08-25 by setting `duplicate_scan_frequency='daily'` and clearing `cwa_duplicate_cache.scan_pending` in `/config/cwa.db` (settings live in the `cwa_settings` table, single row). **Clear `scan_pending=0` before restarting** — otherwise the queued scan re-runs on boot and re-deadlocks.

**Getting a Python stack** (the only way to tell mode 3 from mode 1): the container lacks py-spy and ptrace. `pip install py-spy` inside it, then run it via `docker exec --privileged` (adds SYS_PTRACE without recreating the container, so the frozen state survives):
   `ssh dsfitz "sudo /usr/local/bin/docker exec --privileged calibre-web-automated py-spy dump --pid <cps-pid>"`

**Upstream status (checked 2026-08-26): there is no version to upgrade to.** `latest` and `v4.0.6` are the *same digest* (`sha256:c31a738b…`, published 2026-02-04) — upstream has cut no stable release since Feb 2026, so `docker pull` is a no-op. Only `dev-*` tags are newer (dev-424, 2026-08-07). The bug is known but **unfixed in every published tag**:
- **PR #1177** "fix(db): replace StaticPool with QueuePool to prevent web server deadlock" — **open, unmerged** (last touched 2026-07-05). Its description matches our py-spy dump exactly: `StaticPool` gives all threads a *single shared SQLite connection*, so when the `WorkerThread` running a duplicate scan holds it, the gevent MainThread blocks on the same connection.
- **Issue #1355** "Flask web process deadlocks after book add via UI; container stays Up (unhealthy)" — open, same symptom.
- Related open: #1095 (Duplicate Manager race), #1457 (hybrid prefilter bug), #1217 (127.0.0.1:8083 HTTPConnectionPool failures during ingest — the ingest-processor timeouts we saw).

So **don't bother pulling to fix this**; the `duplicate_scan_frequency='daily'` mitigation above is the actual remedy. A local patch of `StaticPool`→`QueuePool` in `cps/db.py` is the only real fix, and it would be lost on any image update.

**Port check gotcha:** cps binds `[::]:8083`, so it appears in `/proc/net/tcp6`, not `/proc/net/tcp` (and `ss` is not installed). Reading only `tcp4` makes it look like nothing is listening.

Diagnosis order: `docker ps` health flag → `curl -m 30 localhost:8083/login` from inside the container (000+timeout = swapped out; instant refusal = service never started) → `s6-rc -a list | grep calibre` to see if `svc-calibre-web-automated` is active. Note the built-in healthcheck has a 3 s timeout, so the container can show "unhealthy" while actually serving slowly under load. **Key discriminator: check RSS and host CPU/swap first** — swapped-out + thrashing box = mode 1 (restart); normal RSS + idle box = mode 3 (deadlock; take a py-spy dump before restarting, since a restart destroys the evidence).
