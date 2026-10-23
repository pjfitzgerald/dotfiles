---
name: projects-dir-convention
description: PJF's code projects live in ~/code/projects/, not ~/dev or ~/Projects
metadata:
  type: feedback
---

Code projects go in **`~/code/projects/<name>`** (lowercase-hyphenated), e.g.
`optimisedthought-com`, `pfitzgerald-com`, `meal-planner`, `vimarchy`.

Decoys that exist but are empty or unused: `~/Projects`, `~/Work`, `~/dev`.
`~/code/` itself holds only `projects/`, `scripts/`, `script-runner/`, `.claude/`.

**Why:** on 2026-10-22 I created `~/dev/safe-site` without checking, put it in an
AskUserQuestion option, and PJF accepted the option before noticing — then asked
why it wasn't in the normal projects dir. The guess got laundered through a
question, which made it look like a decision.

**How to apply:** check where existing projects live before proposing a path,
and don't bury an unverified path inside an option I'm asking him to approve.
Note `~/docker/<service>/` is separate and is for third-party service compose
stacks, not his own projects. See [[safe-technologies-site]].
