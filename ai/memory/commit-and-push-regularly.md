---
name: commit-and-push-regularly
description: Commit each logical change and push to the remote, don't batch work into one commit at the end
metadata:
  type: feedback
---

Commit per logical change and **push**, rather than leaving work uncommitted or
piling it into one commit at the end of a session.

**Why:** PJF asked for this explicitly on 2026-10-23 for
[[safe-technologies-site]]. It also pairs with his existing batch-reporting rule
("always commit before reporting", so the diff lines up with what I describe) —
the addition here is that a local commit is not enough once a remote exists.

**How to apply:**
- One commit per coherent change, message explaining *why* not just what.
- `git push` after committing when the branch tracks a remote; don't let local
  commits accumulate unpushed.
- No Co-Authored-By lines — see [[feedback_no_coauthor]].
- Before the first push of a new repo, audit for secrets (`git ls-files`,
  `git check-ignore` on .env and data files).
