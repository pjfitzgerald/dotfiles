---
name: webeoc-rest-script
description: Write a one-off WebEOC data script (backfill, normalise, dedup, bulk fix) that runs from the terminal with Node against any environment via the REST API — dry-run by default, env chosen by .env file, writes through a narrow view. Stored in the client repo's `scripts/` folder. Invoke when PJF types /webeoc-rest-script, or asks for a backfill / data-fix / bulk-update script for a WebEOC board (instead of a browser-console paste).
argument-hint: '<what the script should change, in which table/board>'
---

# /webeoc-rest-script

Write (do NOT run) a Node script that fixes data on a WebEOC board through the REST API, the way
`agvic/scripts/backfill-person-search-name.js` does. Background and rationale:
`~/obsidian-vault/webeoc - node REST data scripts.md`.

## 1. Pin down the change

From the arguments (ask only for what the code can't answer):

- **Board** (platform name, e.g. `AgVic Operations` — `board-config.json` `boardName` / `webeoc.board.json` `name`).
- **Table + fields** to write, and the rule that computes each value from the row.
- **Which rows**: all, or a filter (do it in `desired()` — return `null` to skip).

Read the board's code first: field names, how the app maintains this value today (match its formatting
exactly — e.g. the JS that sets it on save), and which views already exist.

## 2. Pick the views

- **Read view** — must return EVERY row: `viewFilters: []` in its `config.json` and `rowcount="0"`, and it
  must declare every field `desired()` reads plus the fields being written. REST honours applied
  viewFilters, so an ordinary list view silently drops rows. Reuse an existing unfiltered source view if
  one exists (agvic: `* - Upload Source`, `* - Data`); otherwise create one.
- **Write view** — an input view that declares ONLY the fields the script writes. A partial REST POST
  re-saves every declared column and blanks the ones the payload omits, so never write through a normal
  input or a wider "Field Update" view. Usually create one: `board-inputs/<Entity> - <Field> Update/` with
  the `.xhtml` below and a `config.json` sidecar copied from a sibling input view (same `table`; drop any
  `globalid` / `tableGlobalid`).

```xml
<html lang="en" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <head>
    <title><Entity> - <Field> Update</title>
    <meta charset="utf-8" />
  </head>
  <!-- REST-only writer for <field>, used by scripts/<name>.js. No UI.
       Declares ONLY <field>: a partial REST POST re-saves every declared column. -->
  <body>
    <form aria-label="Data">
      <input type="hidden" name="<field>" />
    </form>
  </body>
  <applytheme />
</html>
```

## 3. Write the script

- **Location (convention for every client repo):** `scripts/<verb>-<entity>-<field>.js` at the **repo
  root** (e.g. `scripts/backfill-person-search-name.js`). Create `scripts/` if missing. Not inside
  `boards/` — it isn't a board asset.
- Start from `template.js` in this skill's directory: fill the config block (`DEFAULT_BOARD`,
  `READ_VIEW`, `WRITE_VIEW`, `FIELDS`, `desired()`) and the header comment (WHY + views). Keep the
  rest as is: required `--env`, literal `.env` parse, dry run unless `--apply`, write only changed rows,
  serial writes with retry, stop on a first-write 404.
- Plain Node 24, no dependencies (`fetch` is built in). Run the repo's prettier on it if it has one.
- Check: `node --check scripts/<name>.js`, XML well-formedness of the new view.

## 4. Hand over — never run it

Do not run the script against any environment, not even a dry run (it logs in). Commit the script + any
new view (named files), then give PJF the run steps:

1. Push the new view(s) to the target env by name (a whole-board push doesn't create new views); ask
   first / it's his call, per the weboard push rules.
2. Dry run: `node scripts/<name>.js --env <repo>/.env.<env>` — check the `Target:` line and the counts.
3. Write: same command + `--apply`. Expect `failed 0`.
4. Re-run the dry run: expect `to update: 0`. Spot-check one record's Details view (no other field
   changed).

Env files by repo convention: dev = `.env`, other envs = `.env.<env>` at the repo root (agvic:
`.env.demo`; sacfs: `.env.test` / `.env.train` / `.env.prod`). The script needs `WE_URL`, `WE_USER`,
`WE_PASSWORD` (+ optional `WE_POSITION`, `WE_INCIDENT`). Login 401/403 on reads → `--position "<admin position>"`.

## When a browser-console script is still the right tool

- The logic needs the page: board JS (`Global API.js` helpers), the DOM, or a rendered view.
- It must run as a specific end user (permission / position behaviour), not the service account.
- The env has no service-account credentials you can put in a `.env` (e.g. client-only SSO access).
