local vars = require("vars")
local mod, alt = vars.mod, vars.alt

-- Lua has no substitution layer: `..` concatenates and `[[...]]` interprets
-- nothing, so this helper is safe where hyprlang's `$(...)` was not.
local function notify(tag, cmd)
	return ([[notify-send -h string:x-canonical-private-synchronous:%s -t 2000 "$(%s)"]]):format(tag, cmd)
end

local getVol = "wpctl get-volume @DEFAULT_AUDIO_SINK@"
local getMic = "wpctl get-volume @DEFAULT_AUDIO_SOURCE@"
local getBr = "brightnessctl -m"

-- hyprlang `bindel` = repeating + works while locked; `bindl` = locked only.
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd([[wpctl set-volume --limit 2.0 @DEFAULT_AUDIO_SINK@ 10%+ && ]] .. notify("vol", getVol)),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd([[wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%- && ]] .. notify("vol", getVol)),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd([[wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && ]] .. notify("vol", getVol)),
	{ locked = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd([[wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle && ]] .. notify("mic", getMic)),
	{ locked = true }
)
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd([[brightnessctl set 10%+ && ]] .. notify("br", getBr)),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd([[brightnessctl set 10%- && ]] .. notify("br", getBr)),
	{ locked = true, repeating = true }
)

hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + Tab", hl.dsp.focus({ workspace = "previous" }))

-- Clipboard manager
hl.bind(
	alt .. " + V",
	hl.dsp.exec_cmd([[cliphist list | rofi -normal-window -dmenu | cliphist decode | wl-copy && wtype -M ctrl v -m ctrl]])
)

hl.bind(mod .. " + Left", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + Down", hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + Up", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + Right", hl.dsp.focus({ direction = "right" }))

hl.bind(mod .. " + SHIFT + Left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + Down", hl.dsp.window.move({ direction = "down" }))
hl.bind(mod .. " + SHIFT + Up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + Right", hl.dsp.window.move({ direction = "right" }))

hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mod .. " + T", hl.dsp.window.float({ action = "toggle" }))

-- dwindle has no parent container; grouping is the nearest to sway's `focus parent`.
hl.bind(mod .. " + A", hl.dsp.group.toggle())

for i = 1, 4 do
	hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- hyprland has no separate restart, so both keys reload.
hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))

-- A submap only rebinds the keys it defines (unlike sway's `mode`, which grabs
-- the whole keyboard), and `hl.define_submap` does not enter a mode at runtime
-- -- it sets a config-manager flag while the function runs, so every
-- `hl.bind` inside attaches to it.
hl.bind(mod .. " + R", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
	hl.bind("J", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
	hl.bind("K", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
	hl.bind("L", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
	hl.bind("semicolon", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
	hl.bind("Left", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
	hl.bind("Down", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
	hl.bind("Up", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
	hl.bind("Right", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })

	hl.bind("Return", hl.dsp.submap("reset"))
	hl.bind("Escape", hl.dsp.submap("reset"))
	hl.bind(mod .. " + R", hl.dsp.submap("reset"))
end)
