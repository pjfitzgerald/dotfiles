#!/usr/bin/env node
/**
 * <ONE-LINE TITLE> — <Table>.<field(s)>
 *
 * WHY
 * ---
 * <What is wrong in the data, and why a one-off script fixes it.>
 *
 * USAGE
 * -----
 *   node scripts/<name>.js --env <path-to-.env> [--apply]
 *        [--sample N] [--board "<Board>"] [--position P] [--incident I]
 *
 * Dry run by default: logs in, reads every row, prints the counts and a
 * sample of the rows it would change. Writes only with --apply.
 *
 * --env is required (no default, so the target environment is always explicit).
 * The file is parsed literally (KEY=value per line, no quote or $ handling):
 * passwords can contain shell-special characters, so never `source` it.
 * WE_POSITION / WE_INCIDENT are read from the file if present; --position /
 * --incident override them.
 *
 * READ / WRITE VIEWS
 * ------------------
 * Reads <READ_VIEW>: viewFilters [] and rowcount="0", so one GET returns every
 * row (REST honours applied viewFilters, so a normal list view hides rows).
 *
 * Writes through <WRITE_VIEW>, which declares ONLY the fields this script sets.
 * A partial POST re-saves every declared column, so a wider view would blank
 * the columns it declares but this payload omits. If that view is new, create
 * it on the target env with a targeted `weboard push "<WRITE_VIEW>"` first.
 *
 * Only rows whose stored values differ from the computed ones are written, so a
 * second run reports "to update: 0". Each write adds a history entry.
 */
"use strict";

const fs = require("fs");

// ---- script-specific config ----
const DEFAULT_BOARD = "<Board name as on the platform>";
const READ_VIEW = "<unfiltered source view>";
const WRITE_VIEW = "<narrow write view>";
// Every field desired() returns. Checked against the read rows so a missing
// column (not deployed on this env) aborts before any write.
const FIELDS = ["<field>"];

// Return the wanted values for a row as { field: value }, or null to skip it.
// Values are compared as trimmed strings against the stored ones.
function desired(row) {
  // e.g. return { persons_search_name: [row.persons_first_name, row.persons_last_name].join(" ").trim() };
  throw new Error("desired() not implemented");
}
// ---- end config ----

const PAUSE_MS = 400;
const RETRIES = 3;

function fail(msg) {
  console.error("Aborted: " + msg);
  process.exit(1);
}

function parseArgs(argv) {
  const opts = { apply: false, sample: 20, board: DEFAULT_BOARD };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    const next = () => {
      if (i + 1 >= argv.length) fail(`${a} needs a value`);
      return argv[++i];
    };
    if (a === "--env") opts.env = next();
    else if (a === "--apply") opts.apply = true;
    else if (a === "--sample") opts.sample = parseInt(next(), 10);
    else if (a === "--board") opts.board = next();
    else if (a === "--position") opts.position = next();
    else if (a === "--incident") opts.incident = next();
    else fail(`unknown argument ${a}`);
  }
  if (!opts.env) fail("--env <path-to-.env> is required");
  if (!Number.isInteger(opts.sample) || opts.sample < 0) fail("--sample must be a number");
  return opts;
}

// Literal KEY=value parse: no quote stripping, no $ expansion.
function readEnv(path) {
  if (!fs.existsSync(path)) fail(`env file not found: ${path}`);
  const env = {};
  for (const line of fs.readFileSync(path, "utf8").split(/\r?\n/)) {
    const m = line.match(/^([A-Z_][A-Z0-9_]*)=(.*)$/);
    if (m) env[m[1]] = m[2];
  }
  for (const k of ["WE_URL", "WE_USER", "WE_PASSWORD"]) {
    if (!env[k]) fail(`${k} missing from ${path}`);
  }
  return env;
}

const str = (v) => (v == null ? "" : String(v)).trim();

async function login(api, creds) {
  const res = await fetch(api + "/sessions", {
    method: "POST",
    headers: { "Content-Type": "application/json", Accept: "application/json" },
    body: JSON.stringify(creds),
    redirect: "manual",
  });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    fail(`login failed: HTTP ${res.status} ${res.statusText}\n${text.slice(0, 500)}`);
  }
  const cookies = res.headers.getSetCookie();
  if (!cookies.length) fail("login returned no session cookie");
  return cookies.map((c) => c.split(";")[0].trim()).join("; ");
}

async function main() {
  const opts = parseArgs(process.argv.slice(2));
  const env = readEnv(opts.env);
  const api = env.WE_URL.replace(/\/$/, "") + "/api/rest.svc";
  const boardPath = api + "/board/" + encodeURIComponent(opts.board);

  const creds = { username: env.WE_USER, password: env.WE_PASSWORD };
  const position = opts.position || env.WE_POSITION;
  const incident = opts.incident || env.WE_INCIDENT;
  if (position) creds.position = position;
  if (incident) creds.incident = incident;

  console.log(`Target: ${env.WE_URL} (board "${opts.board}") ${opts.apply ? "APPLY" : "DRY RUN"}`);
  const cookie = await login(api, creds);

  // ---- 1. read every row ----
  const res = await fetch(boardPath + "/display/" + encodeURIComponent(READ_VIEW), {
    headers: { Cookie: cookie, Accept: "application/json" },
  });
  if (!res.ok) {
    const text = await res.text().catch(() => "");
    fail(`reading ${READ_VIEW}: HTTP ${res.status} (if 401/403, retry with --position)\n` + text.slice(0, 500));
  }
  const rows = await res.json();
  if (!Array.isArray(rows)) fail(`${READ_VIEW} did not return an array`);
  for (const f of FIELDS) {
    if (rows.length && !rows.some((r) => f in r)) {
      fail(`${READ_VIEW} rows carry no ${f} key: the column is missing on this env, or the view doesn't declare it`);
    }
  }

  // ---- 2. diff ----
  const toUpdate = [];
  let upToDate = 0;
  for (const r of rows) {
    const want = desired(r);
    if (!want) continue;
    const changed = Object.keys(want).filter((k) => str(r[k]) !== str(want[k]));
    if (!changed.length) {
      upToDate++;
      continue;
    }
    const stored = Object.fromEntries(changed.map((k) => [k, str(r[k])]));
    toUpdate.push({ dataid: r.dataid, stored: JSON.stringify(stored), want });
  }
  console.log(`Rows: ${rows.length} | up to date: ${upToDate} | to update: ${toUpdate.length}`);
  if (toUpdate.length && opts.sample) {
    console.table(toUpdate.slice(0, opts.sample).map((u) => ({ ...u, want: JSON.stringify(u.want) })));
    if (toUpdate.length > opts.sample) console.log(`... and ${toUpdate.length - opts.sample} more`);
  }

  if (!opts.apply) {
    console.log("DRY RUN: nothing written. Re-run with --apply to write.");
    return;
  }

  // ---- 3. write, serially ----
  let ok = 0;
  const failed = [];
  for (const u of toUpdate) {
    const url = boardPath + "/input/" + encodeURIComponent(WRITE_VIEW) + "/" + u.dataid;
    let lastErr = null;
    for (let attempt = 1; attempt <= RETRIES; attempt++) {
      try {
        const w = await fetch(url, {
          method: "POST",
          headers: { Cookie: cookie, "Content-Type": "application/json" },
          body: JSON.stringify({ data: JSON.stringify(u.want) }),
        });
        if (!w.ok) throw new Error(`HTTP ${w.status} ${(await w.text()).slice(0, 300)}`);
        lastErr = null;
        break;
      } catch (err) {
        lastErr = err;
        if (attempt < RETRIES) await new Promise((r) => setTimeout(r, PAUSE_MS * attempt * 2));
      }
    }
    if (lastErr) {
      failed.push({ dataid: u.dataid, error: lastErr.message });
      console.error(`failed ${u.dataid}: ${lastErr.message}`);
      // A 404 on the first record means the write view is missing.
      if (ok === 0 && failed.length === 1 && /HTTP 404/.test(lastErr.message)) {
        fail(`${WRITE_VIEW} not found on this env: push it first`);
      }
    } else {
      ok++;
      console.log(`ok ${u.dataid} ${JSON.stringify(u.want)}`);
    }
    await new Promise((r) => setTimeout(r, PAUSE_MS));
  }

  console.log(`Done: updated ${ok}, failed ${failed.length}`);
  if (failed.length) {
    console.table(failed);
    process.exitCode = 1;
  }
}

main().catch((err) => fail(err.stack || String(err)));
