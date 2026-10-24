-- Hyprland personal overrides -- Omarchy only.
--
-- install.sh symlinks these per FILE into ~/.config/hypr/ (not the whole dir):
-- Omarchy ships its own files there and its migrations rewrite them, so a
-- directory symlink would either be clobbered or hide Omarchy's additions.
--
-- monitors.lua is deliberately NOT tracked. It is per-machine (output names,
-- scale, colour-management quirks of whatever panel is attached), so it stays
-- a machine-local file and install.sh leaves it alone. The require below
-- still picks it up from ~/.config/hypr/monitors.lua.

-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Make all windows fully opaque (overrides Omarchy's default 0.985/0.96 and
-- the per-app browser opacity rules, which all load before this).
o.window(".*", { opacity = "1 1" })
