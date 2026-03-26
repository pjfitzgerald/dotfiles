---
name: No co-author on commits
description: Do not add Claude as co-author in git commit messages
type: feedback
---

Do not add "Co-Authored-By: Claude..." lines to git commit messages.

**Why:** User explicitly requested this — they don't want AI attribution in their commit history.

**How to apply:** When committing, omit the co-author trailer entirely.
