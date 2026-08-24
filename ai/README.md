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
| Instructions | `~/.claude/CLAUDE.md` | `~/.config/opencode/AGENTS.md` | `~/.codex/AGENTS.md` | `~/.gemini/GEMINI.md` |
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
- **opencode would load the rules twice.** It reads
  `~/.config/opencode/AGENTS.md` *and* `~/.claude/CLAUDE.md`; both now resolve
  to `ai/AGENTS.md`. `opencode.json` sets `"disableClaudeCodePrompt": true` to
  suppress the second read. Don't remove it.
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
