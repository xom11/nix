local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local act = wezterm.action

-- pwsh shell in windows
local function get_default_prog()
  if wezterm.target_triple:find("windows") then
    return { "pwsh.exe", "-NoLogo" }
  end
  return nil
end
config.default_prog = get_default_prog()

config.font = wezterm.font 'JetBrains Mono'
config.font_size = 11.0

config.color_scheme = 'Catppuccin Macchiato'

config.window_background_opacity = 0.5
config.win32_system_backdrop = 'Acrylic' -- 'Acrylic', 'Mica', 'Tabbed'

config.window_decorations = "RESIZE"

config.keys = {
  { key = '|', mods = 'CTRL|SHIFT', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-', mods = 'CTRL|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'w', mods = 'CTRL|SHIFT', action = wezterm.action.CloseCurrentTab { confirm = true } },
  { key = 'LeftArrow',  mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTabRelative(-1) },
  { key = 'RightArrow', mods = 'CTRL|SHIFT', action = wezterm.action.ActivateTabRelative(1) },
}

return config
