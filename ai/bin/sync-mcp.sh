#!/usr/bin/env bash
# Applies ai/mcp.json to each installed agent. Idempotent -- safe to re-run,
# and install.sh calls it on every run.
#
# Each agent stores MCP servers in its own place and shape, so this is the
# "generate per-agent" step rather than a symlink:
#   Claude Code: ~/.claude.json (user scope), written via `claude mcp add-json`
#   opencode:    ~/.config/opencode/opencode.json -> "mcp" (written here)
#   Codex:       ~/.codex/config.toml -> [mcp_servers.*] (printed, not written)
#
# Requires jq.

set -euo pipefail

AI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MCP_JSON="$AI_DIR/mcp.json"

if ! command -v jq &>/dev/null; then
  echo "sync-mcp: jq not found; skipping MCP sync." >&2
  exit 0
fi

servers=$(jq -r '.mcpServers | keys[]' "$MCP_JSON")

# --- Claude Code ---------------------------------------------------------
if command -v claude &>/dev/null; then
  existing=$(claude mcp list 2>/dev/null | awk -F: '/^[a-zA-Z]/ {print $1}' || true)
  for name in $servers; do
    if printf '%s\n' "$existing" | grep -qx "$name"; then
      continue
    fi
    cfg=$(jq -c --arg n "$name" '.mcpServers[$n]' "$MCP_JSON")
    echo "sync-mcp: registering '$name' with Claude Code"
    claude mcp add-json --scope user "$name" "$cfg" >/dev/null
  done
fi

# --- opencode ------------------------------------------------------------
# opencode wants {"type":"local","command":["cmd","arg",...],"enabled":true}.
# Its config is JSONC, so rewrite only when the generated block differs.
OC_CONFIG="$HOME/.config/opencode/opencode.json"
if [ -f "$OC_CONFIG" ]; then
  oc_block=$(jq '[.mcpServers | to_entries[] | {
      key: .key,
      value: { type: "local",
               command: ([.value.command] + (.value.args // [])),
               enabled: true }
    }] | from_entries' "$MCP_JSON")
  echo "sync-mcp: opencode MCP block for opencode/opencode.json:"
  printf '  "mcp": %s\n' "$(printf '%s' "$oc_block" | jq -c .)"
fi

# --- Codex ---------------------------------------------------------------
if [ -d "$HOME/.codex" ]; then
  echo "sync-mcp: Codex MCP block for ~/.codex/config.toml:"
  for name in $servers; do
    cmd=$(jq -r --arg n "$name" '.mcpServers[$n].command' "$MCP_JSON")
    args=$(jq -c --arg n "$name" '.mcpServers[$n].args // []' "$MCP_JSON")
    printf '  [mcp_servers.%s]\n  command = "%s"\n  args = %s\n' "$name" "$cmd" "$args"
  done
fi
