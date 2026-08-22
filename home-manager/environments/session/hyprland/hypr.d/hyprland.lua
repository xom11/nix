-- Hyprland 0.55+ retired hyprlang and looks for hyprland.lua before any .conf.
-- The .conf tree was deleted 2026-08-20, so there is nothing to fall back to:
-- renaming this file makes Hyprland generate a stub straight into the repo.
-- Old hyprlang version: `git log --diff-filter=D -- '*/hypr.d/**/*.conf'`.
-- This is a different API, not new spelling — see conf.d/system.lua for the
-- `hyprctl dispatch` and key-name changes.

-- Required on rog, not tuning. HDMI hangs off NVIDIA but aquamarine promotes
-- whichever GPU owns a built-in panel (eDP-1 is Intel's), so without this every
-- 4K frame is drawn on the iGPU and copied over, and the cursor blit fails
-- outright. Setting AQ_DRM_DEVICES skips that heuristic and honours this order,
-- so NVIDIA must stay first. Both cards must be listed: NVIDIA alone leaves
-- eDP-1 invisible to Hyprland and the disable below becomes a dead line.
-- Names are udev symlinks from hosts/rog/nvidia.nix — not `card0` (random
-- minor), not `by-path` (contains `:`, the separator). A missing symlink means
-- Hyprland will not start; recover from a TTY. Changing this needs a full
-- session restart: `hyprctl reload` re-runs setenv long after aquamarine read it.
hl.env("AQ_DRM_DEVICES", "/dev/dri/nvidia-card:/dev/dri/intel-card")

-- Must be native `hl.monitor`: kanshi cannot drive Hyprland — it reports
-- "applying profile" while `hyprctl monitors` stays unchanged. scale 2 is an
-- integer ratio, so 1920x1080 of space stays sharp on 4K.
-- All three fields are strings, parsed with hyprlang's old syntax.
-- Disabling eDP-1 is static, so unplugging HDMI blanks this session — recover
-- via SSH or by logging into GNOME.
hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60", position = "0x0", scale = "2" })
hl.monitor({ output = "eDP-1", disabled = true })

-- `require` only globs when the path is explicit (`~/`, `/`, `./`, `../`), and
-- like hyprlang it errors on zero matches. Results are sorted.
require("~/.config/hypr/conf.d/*.lua")

-- Generated from configs/shortcuts/launch-app.toml. No `.lua` suffix:
-- `require` appends it.
require("~/.config/hypr-nix/launch-app")

-- Same key names as hyprlang except `-` becomes `_`; a wrong one shows up in
-- `hyprctl configerrors` rather than failing silently.
hl.config({
	general = {
		border_size = 0,
		gaps_in = 0,
		gaps_out = 0,
		layout = "dwindle",
	},

	decoration = {
		rounding = 0,
	},

	animations = {
		enabled = false,
	},

	-- On since 2026-08-14: Zalo and some older Electron apps are X11-only.
	xwayland = {
		enabled = true,
	},

	-- Default false: activate requests are ignored, so a link clicked in kitty
	-- opens a Brave tab without moving focus. Verified live 2026-08-22.
	misc = {
		focus_on_activate = true,
	},
})

-- Before editing files under `~/.config/hypr`, turn off autoreload — deleting
-- the main config makes Hyprland write a stub into the repo, and `git checkout`
-- unlinks before creating, losing the race against the watcher. `hyprctl
-- keyword` no longer works on the Lua parser; use:
--     hyprctl eval 'hl.config({ misc = { disable_autoreload = true } })'
-- then overwrite in place (`git show HEAD:<path> > <path>`), never unlink.
