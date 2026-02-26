local opts = {
	panel = {
		enabled = true,
		auto_refresh = true,
	},
	suggestion = {
		enabled = true,
		auto_trigger = true,
		debounce = 75,
		keymap = {
			accept = "<M-l>",
			accept_word = "<M-k>",
			dismiss = "<C-]>",
		},
	},
}

-- Apply highlights for Copilot suggestions
-- fg = "#555555", italic = true
-- vim.api.nvim_set_hl(0, "CopilotSuggestion", {
-- 	fg = "#555555",
-- 	italic = true,
-- })

local highlight = {
	CopilotSuggestion = {
		italic = true,
		fg = "#555555",
	},
}
return {
  opts = opts,
}
