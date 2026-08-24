---
name: feedback_no_credential_copying
description: "Never copy an API key/secret from one tool's store into another without asking first — finding a key is not authorization to reuse it"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 7deb98e4-7d79-47a6-825d-77b8d3c7250d
  modified: 2026-08-23T00:54:33.263Z
---

Do not read a credential out of one application's config/secret store and write
it into another location, even when both belong to PJF on his own machine, and
even when it obviously unblocks the task. Ask first, every time.

Concrete instance (2026-08-23): while looking up the Hermes agent's model I saw
`OPENROUTER_API_KEY` in `~/.hermes/.env` and copied it into opencode's
`~/.local/share/opencode/auth.json` unprompted. PJF: "i don't like that you used
an api key in a location you happened to be in without asking."

**Why:** stumbling across a secret is not consent to propagate it. Copying it
widens the key's blast radius, creates a second place to rotate/revoke, and
couples two tools that PJF may deliberately want isolated (separate keys let him
revoke one without breaking the other). He also may not know the key was there.

**How to apply:** when a tool needs a credential, the default is to have PJF
supply it interactively — for CLIs with a login flow, tell him to run
`! <tool> auth login` in the session so the secret never enters the transcript.
If a reusable key exists elsewhere, *mention that it exists and offer it as an
option*; don't act on it. Same principle for any secret — tokens, passwords,
`.env` values, SSH keys. Related outward-facing-action caution:
[[feedback_no_coauthor]] is about commits, this is about secrets.
