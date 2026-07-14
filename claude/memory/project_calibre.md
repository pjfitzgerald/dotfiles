---
name: project-calibre
description: Calibre-Web-Automated on dsfitz — swap-thrash failure modes + s6-rc recovery without full container restart
metadata:
  type: project
---

Calibre-Web-Automated (crocodilestick/calibre-web-automated, v4.0.6) runs on **dsfitz** with a Tailscale sidecar (`calibre-calibre-web-ts-1`, container shares its netns). Web app is `cps.py` on port 8083. See [[project-homelab]] for the box.

Two distinct "not loading" failure modes seen 2026-07 (both downstream of dsfitz swap-thrashing):

1. **App swapped out / wedged**: container "Up X weeks (unhealthy)", `cps.py` alive but RSS ≈ 0, health-check curls hang for days inside the container, HTTP times out. Fix: `docker restart calibre-web-automated`.
2. **Web service never starts after a restart under load**: CWA's `calibre-binaries-setup` s6 service runs a `calibredb --version` check that **times out under IO load and falsely concludes Calibre isn't installed**, then its 5-min re-download can also time out → service exits 1 → `svc-calibre-web-automated` never starts → connection refused on 8083. Fix without another restart roulette:
   `ssh dsfitz "sudo /usr/local/bin/docker exec calibre-web-automated bash -c 's6-rc -u change calibre-binaries-setup; s6-rc -u change svc-calibre-web-automated'"`
   (Calibre binaries persist at `/app/calibre`; the re-run usually succeeds and the web service comes up in seconds.)

Diagnosis order: `docker ps` health flag → `curl -m 30 localhost:8083/login` from inside the container (000+timeout = swapped out; instant refusal = service never started) → `s6-rc -a list | grep calibre` to see if `svc-calibre-web-automated` is active. Note the built-in healthcheck has a 3 s timeout, so the container can show "unhealthy" while actually serving slowly under load.
