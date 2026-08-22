local vars = require("vars")
local mod, alt = vars.mod, vars.alt
local modAlt = mod .. " + " .. alt

-- `hyprland.start` is exec-once: `hyprctl reload` re-registers the callback
-- but does not re-fire it (deliberate — re-running would stack a second
-- cliphist and fcitx5). `hl.exec_cmd` runs now; `hl.dsp.exec_cmd` only builds
-- a closure for a keybind and would silently do nothing here.
hl.on("hyprland.start", function()
	hl.exec_cmd("noctalia-shell")
	hl.exec_cmd("wl-paste --watch cliphist store")
	hl.exec_cmd("fcitx5 -rd")
end)

-- Device name must match `hyprctl devices` on rog. rog never suspends on idle
-- (logind IdleAction=ignore), so this switch is the only path into suspend.
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("systemctl suspend"), { locked = true })

-- Target `lockScreen`, function `lock`: the target alone answers "Function
-- required to send message." and still exits 0.
hl.bind(modAlt .. " + L", hl.dsp.exec_cmd("noctalia-shell ipc call lockScreen lock"))
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

-- Lua renames hyprlang keys `:`->`.` and `-`->`_`; a wrong name lands in
-- `hyprctl configerrors`, not a broken config. One shared `sensitivity` here
-- vs sway's touchpad/pointer split.
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
