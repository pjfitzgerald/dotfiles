# ai/ — agent-neutral config

Single source of truth for coding-agent config. Nothing in here is specific to
one agent; `install.sh` symlinks each item into whatever path a given agent
expects, and per-agent adapter dirs (`claude/`, `opencode/`, `codex/`,
`gemini/`) hold only the harness settings that genuinely cannot be shared.

## Layout

| Path | What it is |
| --- | --- |
| `AGENTS.md` | User-level instructions. The one file every agent loads. |
| `skills/` | `SKILL.md`-format skills. |
| `commands/` | Slash-command prompt bodies (`<name>.md`). Empty for now. |
| `agents/` | Subagent definitions. Empty for now. |
| `memory/` | Memory notes plus the `MEMORY.md` index. |
| `context/` | Context injectors: read a prompt on stdin, write context on stdout. |
| `mcp.json` | MCP server declarations. |
| `bin/sync-mcp.sh` | Applies `mcp.json` to each installed agent. |

## Where each agent reads it from

| | Claude Code | opencode | Codex | Gemini CLI |
| --- | --- | --- | --- | --- |
| Instructions | `~/.claude/CLAUDE.md` | `~/.claude/CLAUDE.md` (fallback) | `~/.codex/AGENTS.md` | `~/.gemini/GEMINI.md` |
| Skills | `~/.claude/skills` | `~/.config/opencode/skill` | — | — |
| Commands | `~/.claude/commands` | `~/.config/opencode/command` | `~/.codex/prompts` | — |
| Subagents | `~/.claude/agents` | `~/.config/opencode/agent` | — | — |
| Memory | `~/.claude/projects/<cwd>/memory` | via skills | — | — |
| Hooks | `~/.claude/hooks` | plugins (not wired) | — | — |
| Settings | `claude/settings.json` | `opencode/opencode.json` | `codex/config.toml` | `gemini/settings.json` |

## Gotchas

- **Claude Code does not read `AGENTS.md`.** It hardcodes `CLAUDE.md`
  discovery; the only `AGENTS.md` handling in the binary is its Codex importer.
  So `AGENTS.md` is the real file and `~/.claude/CLAUDE.md` is a symlink to it.
  Same at project level: a repo's `AGENTS.md` is real, its `CLAUDE.md` is a
  committed symlink.
- **opencode reads two instruction paths, so only link one.** It loads
  `~/.config/opencode/AGENTS.md` *and* `~/.claude/CLAUDE.md`. Linking both to
  `ai/AGENTS.md` puts the same rules in context twice, so `install.sh`
  deliberately creates only the `~/.claude/CLAUDE.md` one and lets opencode's
  fallback find it. Don't "fix" this by adding the opencode-side symlink.
  `"disableClaudeCodePrompt"` is **not a config key** — opencode silently drops
  unknown top-level keys, so setting it in `opencode.json` does nothing. The
  real switch is the env var `OPENCODE_DISABLE_CLAUDE_CODE_PROMPT` (or the
  broader `OPENCODE_DISABLE_CLAUDE_CODE`), and it is all-or-nothing: it also
  removes `CLAUDE.md` from opencode's *project-level* walk-up list, which would
  blind it in every repo that has a `CLAUDE.md` and no `AGENTS.md`. Not worth it.
- **Skills do not have this problem.** opencode dedupes skills by name, so the
  `~/.config/opencode/skill` link and its `~/.claude/skills` scan resolving to
  the same directory is harmless — verified with `opencode debug skill`.
- **Gemini's `contextFileName` is unverified** — gemini-cli isn't installed on
  any of these machines yet. `install.sh` links both `~/.gemini/AGENTS.md` and
  `~/.gemini/GEMINI.md` so it works regardless. Confirm with `/memory show` on
  first use, then drop whichever link is dead.
- **Keep `AGENTS.md` agent-neutral.** Name capabilities ("the web-fetch tool"),
  not one harness's tool names. Anything harness-specific belongs in that
  agent's adapter file.
- **Skills are the portable unit; hooks are not.** Keep hook logic in
  `context/` as plain stdin→stdout scripts so each agent only needs a few
  lines of wiring, not a rewrite.
- `skills/terminal-browser` is a symlink into a machine-local install under
  `~/.local/share`, so it is gitignored rather than committed.
