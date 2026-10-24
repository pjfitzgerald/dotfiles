-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")


-- PJF 

o.bind("SUPER + bracketright", "Brightness up", "omarchy-brightness-display +5%", { locked = true, repeating = true })
o.bind("SUPER + bracketleft", "Brightness down", "omarchy-brightness-display 5%-", { locked = true, repeating = true })
o.bind("SUPER + SHIFT + bracketright", "Brightness maximum", "omarchy-brightness-display 100%", { locked = true })
o.bind("SUPER + SHIFT + bracketleft", "Brightness minimum", "omarchy-brightness-display 1%", { locked = true })
o.bind("SUPER + ALT + bracketright", "Brightness up precise", "omarchy-brightness-display +1%", { locked = true, repeating = true })
o.bind("SUPER + ALT + bracketleft", "Brightness down precise", "omarchy-brightness-display 1%-", { locked = true, repeating = true })

-- Google Photos webapp binding (Omarchy default) - not an installed app.
hl.unbind("SUPER + SHIFT + P")

-- Pomodoro (techywilbur.pomodoro): SUPER+ALT+P opens/closes the bar popup.
o.bind("SUPER + ALT + P", "Pomodoro panel", "omarchy-shell shell toggle techywilbur.pomodoro")

-- Toggle kanata home row mods on/off (start/stop the user service).
o.bind("SUPER + F1", "Toggle home row mods", "/home/pjf/.local/bin/kanata-toggle")














-- Host workspace escape while a client grabs the keyboard (GLKVM / Comet KVM,
-- browser Keyboard Lock, VMs). Those apps use the Wayland
-- keyboard-shortcuts-inhibit protocol, which silences Hyprland binds; the
-- dont_inhibit option (bind flag `p`) makes these fire anyway. Trade-off:
-- SUPER+<n> and SUPER+TAB can no longer be forwarded to the remote machine.
for workspace = 1, 10 do
  local key = "SUPER + code:" .. tostring(workspace + 9)
  hl.unbind(key)
  o.bind(
    key,
    "Switch to workspace " .. workspace,
    hl.dsp.focus({ workspace = tostring(workspace) }),
    { dont_inhibit = true }
  )
end

hl.unbind("SUPER + TAB")
o.bind("SUPER + TAB", "Next workspace", hl.dsp.focus({ workspace = "e+1" }), { dont_inhibit = true })
hl.unbind("SUPER + SHIFT + TAB")
o.bind("SUPER + SHIFT + TAB", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }), { dont_inhibit = true })
hl.unbind("SUPER + CTRL + TAB")
o.bind("SUPER + CTRL + TAB", "Former workspace", hl.dsp.focus({ workspace = "previous" }), { dont_inhibit = true })
