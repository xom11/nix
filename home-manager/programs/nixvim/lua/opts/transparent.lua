local opts = {
	extra_groups = {
		-- NeoTree
		"NeoTreeNormal",
		"NeoTreeNormalNC",
		"NeoTreeFloat",
		"NeoTreeFloatBorder",
		-- Telescope
		"TelescopeNormal",
		"TelescopeBorder",
		"TelescopePromptNormal",
		"TelescopePromptBorder",
		"TelescopeResultsNormal",
		"TelescopePreviewNormal",
		-- Lualine
		"LualineNormal",
		"LualineNC",
		-- FzfLua
		"FzfLuaBorder",
		"FzfLuaNormal",
		"FzfLuaTitle",
		"FzfLuaPreviewBorder",
		"FzfLuaPreviewNormal",
		"FzfLuaPreviewTitle",
	},
	exclude_groups = {
		"CursorLine",
	},
}

local config = function(_, opts)
  local transparent = require("transparent")

  transparent.setup(opts)

  transparent.clear_prefix("NeoTree")
  transparent.clear_prefix("Telescope")

  vim.cmd("highlight Normal guibg=NONE")
  vim.cmd("highlight Lualine guibg=NONE")
  vim.cmd("highlight Lualine guifg=NONE")
  vim.cmd("highlight NormalNC guibg=NONE")
end

config(nil, opts)
