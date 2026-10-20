---
name: stream-layout
description: Apply the orchestrator/stream tmux layout (shell | Claude 50% | nvim) to the current window and remind PJF of the keybind (prefix+A). Invoke when PJF types /stream-layout or asks to lay out / fix the layout of the current tmux window.
---

# /stream-layout

1. Run `~/dotfiles/bin/tmux-stream-layout` (no args) via Bash. It lays out the window this session's pane is
   in (falling back to the active pane of the most recent tmux client), keeps the claude pane in the centre at
   50%, puts nvim right and a shell left, and creates any missing pane. It refuses windows with more than 3 panes.
2. Reply in one line: the script's result, then **"Keybind: `prefix+A` (Ctrl-Space, then Shift-a)."**
   If it failed, show the error.
