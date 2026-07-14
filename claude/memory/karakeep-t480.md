---
name: karakeep-t480
description: "Karakeep docker stack location, management, and Tailscale node after migrating off dsfitz"
metadata: 
  node_type: memory
  type: project
  originSessionId: b8aef220-38ce-4968-a4ad-4f90bbe1812f
---

Karakeep (bookmark app) runs on **t480** (Ubuntu 25.10, ssh `t480` as `pjf`, who is in the `docker` group so no sudo needed). Migrated here from the Synology **dsfitz** on 2026-06-10 because dsfitz had only 3.8GB RAM and was swap-thrashing (load dominated by IO wait, not CPU); t480 has 22GB RAM. The problem was never Tailscale (path is direct, ~11ms).

- Compose dir: `/home/pjf/docker/karakeep/` — `compose.yaml`, `.env` (secrets: NEXTAUTH_SECRET, MEILI_MASTER_KEY, OPENAI_API_KEY; TS_AUTHKEY empty/unused), `data/` (SQLite db.db + assets), `meilisearch/`, `ts-state/`, `config/`. `compose.yaml.bak` holds older (dsfitz) paths. `~/docker/` is the dedicated parent for all docker compose stacks on t480 — new stacks go in their own subfolder there.
- Stack: `karakeep-app`, `karakeep-chrome`, `karakeep-meilisearch` (v1.13.3), plus a `tailscale/tailscale` sidecar (`karakeep-ts`, userspace mode) that owns the Tailscale node **`karakeep`** (100.83.101.55) and serves the app at `https://karakeep.astrapia-degree.ts.net`. The node identity lives in `ts-state/` — moving that dir moved the node + URL with zero config change.
- Manage: `cd /home/pjf/docker/karakeep && docker compose ps|up -d|down|logs`.

Rollback copy still exists at `dsfitz:/volume2/docker/karakeep/` (stopped via `compose down`). **Do not `compose up` on dsfitz while t480 is running** — both share the same `ts-state`, so they'd conflict over the `karakeep` node. On dsfitz, docker needs sudo at full path `/usr/local/bin/docker` (not in sudo's PATH), and sudo needs a password.

If RAM is added to dsfitz later, this could move back. See [[immich-go-dsfitz]] (Immich also runs on dsfitz and competes for its RAM).
