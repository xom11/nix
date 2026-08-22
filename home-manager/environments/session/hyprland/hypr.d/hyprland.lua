-- Hyprland 0.55+ reads hyprland.lua; the .conf tree is deleted, so renaming
-- this file makes Hyprland generate a stub straight into the repo. Different
-- API, not new spelling -- see conf.d/system.lua for the key-name changes.

-- Required on rog, not tuning. HDMI hangs off NVIDIA but aquamarine promotes
-- whichever GPU owns a built-in panel (eDP-1 is Intel's), so without this
-- every 4K frame is drawn on the iGPU and copied over, and the cursor blit
-- fails outright. NVIDIA must stay first, and BOTH cards must be listed --
-- NVIDIA alone leaves eDP-1 invisible. Names are udev symlinks from
-- hosts/rog/nvidia.nix (not `card0`, random minor). Changing this needs a
-- full session restart: `hyprctl reload` re-runs setenv long after
-- aquamarine read it.
hl.env("AQ_DRM_DEVICES", "/dev/dri/nvidia-card:/dev/dri/intel-card")

-- Must be native `hl.monitor`: kanshi cannot drive Hyprland -- it reports
-- "applying profile" while nothing changes. eDP-1 disabled here is STATIC:
-- unplugging HDMI blanks this session; recover via SSH or a tty login.
hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@60", position = "0x0", scale = "2" })
hl.monitor({ output = "eDP-1", disabled = true })

-- Glob only runs when the path is explicit (`~/`, `/`, `./`), errors on zero matches.
require("~/.config/hypr/conf.d/*.lua")

require("~/.config/hypr-nix/launch-app")

-- Key names as hyprlang except `-` becomes `_`; a wrong one shows up in
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

	-- Default false: a link clicked in kitty opens a Brave tab without moving
	-- focus. Verified live 2026-08-22.
	misc = {
		focus_on_activate = true,
	},
})

-- Before editing files under `~/.config/hypr`, turn off autoreload — deleting
-- the main config makes Hyprland write a stub into the repo, and `git
-- checkout` unlinks before creating, losing the race against the watcher:
--     hyprctl eval 'hl.config({ misc = { disable_autoreload = true } })'
-- then overwrite in place (`git show HEAD:<path> > <path>`), never unlink.
