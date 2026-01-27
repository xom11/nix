local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action
local mux = wezterm.mux
local mod = "CTRL|SHIFT"

-- pwsh shell in windows
local function get_default_prog()
	if wezterm.target_triple:find("windows") then
		return { "pwsh.exe", "-NoLogo" }
	end
	return nil
end
config.default_prog = get_default_prog()

config.font = wezterm.font("JetBrains Mono")
config.font_size = 14.0
config.color_scheme = "Catppuccin Macchiato"
config.automatically_reload_config = true

-- full screen startup
wezterm.on("gui-startup", function()
	local tab, pane, window = mux.spawn_window({})
	window:gui_window():maximize()
end)

-- opacity
config.window_background_opacity = 0.8
config.win32_system_backdrop = "Acrylic" -- 'Acrylic', 'Mica', 'Tabbed'

config.window_decorations = "RESIZE"

config.keys = {
	{ key = "|", mods = mod, action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = mod, action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "w", mods = mod, action = wezterm.action.CloseCurrentPane({ confirm = false }) },
	{ key = "LeftArrow", mods = mod, action = wezterm.action.ActivateTabRelative(-1) },
	{ key = "RightArrow", mods = mod, action = wezterm.action.ActivateTabRelative(1) },
	{ key = "<", mods = mod, action = wezterm.action.ActivateTabRelative(-1) },
	{ key = ">", mods = mod, action = wezterm.action.ActivateTabRelative(1) },
	{ key = "h", mods = mod, action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "l", mods = mod, action = wezterm.action.ActivatePaneDirection("Right") },
	{ key = "k", mods = mod, action = wezterm.action.ActivatePaneDirection("Up") },
	{ key = "j", mods = mod, action = wezterm.action.ActivatePaneDirection("Down") },
	{ key = "n", mods = mod, action = wezterm.action.ToggleFullScreen },
}
config.enable_scroll_bar = false
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
return config
