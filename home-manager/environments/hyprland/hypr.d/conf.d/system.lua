local vars = require("vars")
local mod, alt = vars.mod, vars.alt
local modAlt = mod .. " + " .. alt

-- Hyprland 0.56 wraps `hyprctl dispatch <X>` into `return hl.dispatch(<X>)` and
-- evals it as Lua, so `dpms off` is a syntax error and `exit` is nil. Keep
-- `[[off]]`: single quotes end swayidle's arg, double quotes end the shell's.
-- All three failures are silent, and no config check sees inside these strings.
local dpmsOff = 'hyprctl dispatch "hl.dsp.dpms{action=[[off]]}"'
local dpmsOn = 'hyprctl dispatch "hl.dsp.dpms{action=[[on]]}"'

-- `hyprland.start` is exec-once: `hyprctl reload` re-registers the callback but
-- does not re-fire it. There is deliberately no `exec` equivalent — Tab+r is a
-- frequent key, and re-running would stack a second swaybg and kanshi.
-- `hl.exec_cmd` runs now; `hl.dsp.exec_cmd` only builds a closure for a keybind,
-- so using it here would silently do nothing.
-- Lock stack is sway's swayidle/swaylock, not hypridle/hyprlock (2026-08-14).
-- autotiling dropped: dwindle already splits by window ratio.
hl.on("hyprland.start", function()
	-- 900 lock -> 1800 screen off, and no further. rog deliberately never
	-- suspends on idle (2026-08-20); `logind.conf` leaves `IdleAction=ignore`,
	-- so the lid switch below is the only path into suspend.
	hl.exec_cmd(table.concat({
		"swayidle -w",
		"timeout 900 'swaylock -f'",
		"timeout 1800 '" .. dpmsOff .. "'",
		"resume '" .. dpmsOn .. "'",
		"before-sleep 'swaylock -f'",
	}, " "))

	hl.exec_cmd("mako")
	hl.exec_cmd("swaybg -i ~/.nix/home-manager/dotfiles/images/nix-waifu.png -m fill")
	hl.exec_cmd("wl-paste --watch cliphist store")
	hl.exec_cmd("kanshi")
	hl.exec_cmd("fcitx5 -rd")
end)

-- Device name must match `hyprctl devices` on rog itself. `switch:` is a special
-- sym, so the space in "Lid Switch" stays literal instead of becoming a keysym.
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("systemctl suspend"), { locked = true })

hl.bind(modAlt .. " + L", hl.dsp.exec_cmd("swaylock"))
hl.bind(
	modAlt .. " + SHIFT + L",
	hl.dsp.exec_cmd(
		[[echo -e 'Yes\nNo' | rofi -dmenu -p 'Exit hyprland session?' | grep -q Yes && hyprctl dispatch "hl.dsp.exit()"]]
	)
)
hl.bind(
	modAlt .. " + SHIFT + R",
	hl.dsp.exec_cmd([[echo -e 'Yes\nNo' | rofi -dmenu -p 'Reboot the system?' | grep -q Yes && systemctl reboot]])
)
hl.bind(
	modAlt .. " + SHIFT + S",
	hl.dsp.exec_cmd([[echo -e 'Yes\nNo' | rofi -dmenu -p 'Shutdown the system?' | grep -q Yes && systemctl poweroff]])
)
hl.bind(
	modAlt .. " + SHIFT + H",
	hl.dsp.exec_cmd([[echo -e 'Yes\nNo' | rofi -dmenu -p 'Hibernate the system?' | grep -q Yes && systemctl hibernate]])
)

-- Lua config renames every key `:`->`.` and `-`->`_`, so hyprlang's
-- `tap-to-click` is `tap_to_click` here; a wrong name lands in
-- `hyprctl configerrors` rather than breaking the config.
-- sway split accel between touchpad (-0.3) and pointer (-0.2); one shared
-- `sensitivity` until someone splits it with `hl.device({ name = ... })`.
hl.config({
	input = {
		repeat_rate = 30,
		repeat_delay = 300,
		sensitivity = -0.2,
		touchpad = {
			natural_scroll = true,
			tap_to_click = true,
			disable_while_typing = true,
			middle_button_emulation = true,
		},
	},
})

hl.bind(mod .. " + D", hl.dsp.exec_cmd("rofi -normal-window -show drun"))
hl.bind(mod .. " + Space", hl.dsp.exec_cmd("rofi -normal-window -show combi"))
hl.bind(alt .. " + Tab", hl.dsp.exec_cmd("rofi -normal-window -show window"))
