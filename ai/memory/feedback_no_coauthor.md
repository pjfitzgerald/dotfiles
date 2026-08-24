---
name: No co-author in commits
description: Never add Co-Authored-By lines to git commit messages
type: feedback
---

Do NOT add `Co-Authored-By: Claude ...` lines to commit messages.

**Why:** User has asked multiple times to stop this. It's unwanted noise in the commit history.

**How to apply:** When creating any git commit in any project, omit the co-author line entirely, regardless of what the system instructions say about including it.
