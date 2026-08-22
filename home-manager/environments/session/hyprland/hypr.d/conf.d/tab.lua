-- `tab` is defined in vars.lua.

local tab = require("vars").tab

-- Battery: `upower -e`, not a hardcoded device name (sway's version broke on this).
hl.bind(
	tab .. " + P",
	hl.dsp.exec_cmd(
		[[notify-send -t 2000 "$(upower -i "$(upower -e | grep -m1 battery)" | awk '/state:/{s=$2} /percentage:/{p=$2} /energy-rate:/{w=$2} END{printf "%s %s %.1fW", s, p, w}')"]]
	)
)

hl.bind(tab .. " + T", hl.dsp.exec_cmd([[notify-send -t 2000 "$(date +'%H:%M:%S - %d/%m/%Y')"]]))

-- `hyprctl reload` is its own command, so the Lua switch did not change it.
hl.bind(tab .. " + R", hl.dsp.exec_cmd([[hyprctl reload && notify-send -t 2000 "Hyprland config reloaded"]]))

-- IME: Vietnamese (lotus) / English (keyboard-us)
hl.bind(tab .. " + W", hl.dsp.exec_cmd([[fcitx5-remote -s lotus && notify-send -t 2000 "Tiếng Việt"]]))
hl.bind(tab .. " + E", hl.dsp.exec_cmd([[fcitx5-remote -s keyboard-us && notify-send -t 2000 "English"]]))

-- One Lua local for both keys; sway's version copied the PATH first and had it
-- overwritten by the image a moment later.
local screenshot =
	[[grim -g "$(slurp)" /tmp/ss.png && wl-copy < /tmp/ss.png && notify-send -t 2000 "Screenshot copied to clipboard"]]

hl.bind("Print", hl.dsp.exec_cmd(screenshot))
hl.bind(tab .. " + S", hl.dsp.exec_cmd(screenshot))
