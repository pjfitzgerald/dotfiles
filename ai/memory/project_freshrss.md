---
name: project-freshrss
description: "FreshRSS runs on t480 (fully local SSD, SQLite) — migrated off dsfitz 2026-06-27"
metadata: 
  node_type: memory
  type: project
  originSessionId: 5ab9c459-450a-45c1-9cd2-8eaea1059d8d
---

FreshRSS (RSS reader) **migrated from dsfitz to t480 on 2026-06-27**. Unlike Nextcloud/Paperless/Immich, it does **not** use the app-on-t480/data-on-NAS split: it's a small SQLite app (~85M total, one user `patrick` with 94 feeds / ~4089 entries) with no bulk data, so **everything lives on t480's local SSD** (`~/docker/freshrss/{data,extensions}`) — no NFS volume. SQLite must never run over NFS anyway.

Compose at `~/docker/freshrss/docker-compose.yml`, image `freshrss/freshrss:latest`, `container_name: freshrss`, `TZ=Australia/Melbourne`, `CRON_MIN=*/20`, served at `http://t480.astrapia-degree.ts.net:8085` (8085:80). Data was copied by stopping the dsfitz container, then streaming `tar` of `/volume2/docker/freshrss/{data,extensions}` through a root alpine helper container over ssh (dsfitz sudo is docker-only, so couldn't scp the root-owned files directly). The freshrss entrypoint fixed file ownership on first start.

**Login username is `patrick`** (not `pjf`) — `default_user` in `data/config.php`; `auth_type=form`. If the password challenge fails after migration ("Password mismatch" in the user log), reset it via the CLI: `docker exec -u www-data freshrss php /var/www/FreshRSS/cli/update-user.php --user patrick --password '<new>'` (rewrites the bcrypt hash in the current format).

The **old dsfitz container is left stopped with `restart=no`** — don't restart it (second SQLite writer). Same migration rationale as [[project_paperless]] / [[project_nextcloud]] (dsfitz is RAM-starved); overview in [[project_homelab]]. Backups: in scope for the n54l services repo (path updated to t480).
