-- `tab` is defined in vars.lua.

local tab = require("vars").tab

-- The sway version hardcoded a Snapdragon battery name, which does not exist on
-- this machine, so the key printed nothing. `upower -e` is host-independent.
hl.bind(
	tab .. " + P",
	hl.dsp.exec_cmd(
		[[notify-send -t 2000 "$(upower -i "$(upower -e | grep -m1 battery)" | awk '/state:/{s=$2} /percentage:/{p=$2} /energy-rate:/{w=$2} END{printf "%s %s %.1fW", s, p, w}')"]]
	)
)

hl.bind(tab .. " + T", hl.dsp.exec_cmd([[notify-send -t 2000 "$(date +'%H:%M:%S - %d/%m/%Y')"]]))

-- `hyprctl reload` is its own command, not a `dispatch`, so the Lua switch did
-- not change its syntax -- unlike the dispatch calls in system.lua.
hl.bind(tab .. " + R", hl.dsp.exec_cmd([[hyprctl reload && notify-send -t 2000 "Hyprland config reloaded"]]))

-- IME: Vietnamese (lotus) / English (keyboard-us)
hl.bind(tab .. " + W", hl.dsp.exec_cmd([[fcitx5-remote -s lotus && notify-send -t 2000 "Tiếng Việt"]]))
hl.bind(tab .. " + E", hl.dsp.exec_cmd([[fcitx5-remote -s keyboard-us && notify-send -t 2000 "English"]]))

-- The sway version prefixed `echo -n /tmp/ss.png | wl-copy`, which copied the
-- PATH only to be overwritten by the IMAGE a moment later. hyprlang repeated this
-- command verbatim in both bindings because its variable substitution against
-- `$(slurp)` was never measured; a Lua local is just a variable, so it can be
-- shared.
local screenshot =
	[[grim -g "$(slurp)" /tmp/ss.png && wl-copy < /tmp/ss.png && notify-send -t 2000 "Screenshot copied to clipboard"]]

hl.bind("Print", hl.dsp.exec_cmd(screenshot))
hl.bind(tab .. " + S", hl.dsp.exec_cmd(screenshot))
