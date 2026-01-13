local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action
local mux = wezterm.mux

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
	{ key = "|", mods = "CTRL|SHIFT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "-", mods = "CTRL|SHIFT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "w", mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentTab({ confirm = true }) },
	{ key = "LeftArrow", mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },
	{ key = "RightArrow", mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(1) },
	{
		key = "n",
		mods = "SHIFT|CTRL",
		action = wezterm.action.ToggleFullScreen,
	},
  {
    key = "c",
    mods = "CMD",
    action = wezterm.action.CopyTo("Clipboard"),
  }
	-- {
	-- 	key = "c",
	-- 	mods = "CTRL",
	-- 	action = wezterm.action_callback(function(window, pane)
	-- 		local selection_text = window:get_selection_text_for_pane(pane)
	-- 		local is_selection_active = string.len(selection_text) ~= 0
	-- 		if is_selection_active then
	-- 			window:perform_action(wezterm.action.CopyTo("ClipboardAndPrimarySelection"), pane)
	-- 		else
	-- 			window:perform_action(wezterm.action.SendKey({ key = "c", mods = "CTRL" }), pane)
	-- 		end
	-- 	end),
	-- },
}
config.enable_scroll_bar = false
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
return config
