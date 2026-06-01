# CLAUDE.md (User-level)

This file applies to all projects and provides global guidance to Claude Code.

## About Me

- I go by PJF
- macOS (Apple Silicon) is my primary development environment
- I also work in WSL environments
- Editor: Neovim (kickstart.nvim-based config)
- Terminal multiplexer: tmux
- Shell: zsh
- Dotfiles repo: ~/dotfiles

## Preferences

- Be concise and direct. Don't over-explain.
- When making changes, keep working until the goal is fully achieved rather than stopping to ask for confirmation at every step.
- When you discover issues or improvements during a task, fix them inline rather than just reporting them.
- Prefer editing existing files over creating new ones.
- Use Homebrew for package management on macOS.
- Do not add Co-Authored-By lines to git commits.
- **Keep docs in sync with the change that triggered them.** When modifying a documented system or tool (Obsidian notes, CLAUDE.md files, READMEs, in-tool `--help` / usage text, memory files), update the relevant docs as part of the same change — don't defer to "later". Find every doc that references the thing you changed by searching for the feature/command/path/symbol name across likely locations (project docs, user-level CLAUDE.md, vault zettelkasten, memory dir). Skip only when the change is purely internal (refactor, dead-code removal, comment edits) and a doc reader wouldn't notice. If the doc surface to update is large or ambiguous, flag it and ask before sprawling.
- **End-of-turn summaries: restate each question/task with its answer.** When PJF's prompt contains multiple questions or tasks (typically a bulleted or dashed list), the end-of-turn summary should briefly restate each item alongside what I did/answered. This means he can read the summary top-to-bottom without scrolling back to re-load the question context. One terse line per item is enough — keep prose minimal, but make the restatement explicit. Format: short paraphrase of the question/task in bold (or as the lead clause), then the answer/result on the same line or immediately below. For single-task prompts, the existing concise direct summary is fine — don't manufacture restatement when there's only one thing. See `<vault>/zettelkasten/claude - end-of-turn summary format.md` for the rationale and worked example.

## Tools & Stack

- Package manager: Homebrew (Apple Silicon, /opt/homebrew)
- Node version manager: nvm
- Languages: Python, TypeScript, Ruby, Lua
- LSP servers: pyright, ts_ls, ruby_lsp, lua_ls

## WebEOC / weboard work — global rules

These apply to any client board project (CSG, DPIRD, NTFES, QFD, sa-ses, watercorp, AgVic, and any future ones).

### Never run `weboard push` or `weboard pull` without asking

`weboard dev` (file-watcher / live-sync) and `weboard push` / `weboard pull` use the same upload/download pipeline. Running them concurrently can race and corrupt state — local files overwritten by partial pushes, remote diverging from local, lost work.

- Before suggesting OR running `weboard push`, `weboard pull`, or anything that uses the same pipeline, **ask first**: "OK to run `weboard push <asset>` — is `weboard dev` running?" Wait for the green light.
- Same principle for `webeoc-lists push` (separate tool, same caution).
- If editing a per-view `config.json` (e.g. adding viewFilters), call out that the change won't take effect until pushed, and ASK rather than push silently.
- Exception: PJF himself running `weboard dev` is fine — that's his development loop. The problem is *me* triggering parallel platform operations.

### WebEOC date format — body locale attributes pattern

For dd/mm/yyyy display in MDB datepicker (and all date-aware widgets) without breaking save round-trips:

- Set the platform locale at the **`<body>` level**, NOT per-field via `data-mdb-format`.
- `data-mdb-format="dd/mm/yyyy"` on individual datepicker wrappers causes a parser mismatch — MDB displays in dd/mm/yyyy but WebEOC's underlying parser expects whatever the platform locale says, so saved dates get misinterpreted and corrupt records can result.

Required body-level wiring on every input view that has date fields:

```xml
<xsl:variable name="current_date" select="/data/@currentdate" />
<xsl:variable name="timezone">
  <expression name="exp_timezone">@timezone</expression>
</xsl:variable>
<xsl:variable name="is_return" select="/data/ViewParameter[@name='isReturn'] = 'true'" />
<body
  class="..."
  data-webeocdatetimeformat="{data/@webeocdatetimeformat}"
  data-webeocdateformat="{data/@webeocdateformat}"
  data-webeoctimezone="{$timezone}"
  data-webeocdaylight="{data/@daylight}"
  data-is-return="{$is_return}"
>
```

Then a normal `<div data-mdb-datepicker-init="true" data-mdb-input-init="true" data-mdb-inline="true">` wrapper with `<input type="text" fieldtype="datetime" />` — no `data-mdb-format` override.

PJF's `dates.md` Obsidian note (zettelkasten) covers related patterns: `<value-of select="date:formatdate(@field, /data/@webeocdatetimeformat)" />` for details views, SQL `FORMAT(dbo.convert2Local(...), 'dd/MM/yyyy')` expressions for explicit per-expression formatting.

### Multi-task batch reporting format

When PJF gives a list of TODOs to action in one batch:

- Per item: confirmation + a one-or-two-sentence change summary. Don't over-explain.
- Add a quick test flow only when the change is hard to verify from the diff (UI behaviour, runtime logic, navigation).
- Flag issues encountered while making changes — ambiguity in scope, blocking unknowns, things that needed a workaround.
- Never dump the diff or explain every line; PJF reads the diff himself.
- If a task is ambiguous, surface as a blocker and ask, OR pick a reasonable interpretation and explicitly flag the assumption.
- Always commit before reporting (so the diff lines up with what's described).
