-- https://github.com/kylechui/nvim-surround?tab=readme-ov-file#rocket-usage
-- add, delete, change surroundings (parentheses, brackets, quotes, tags, etc.)
local opts = {
	settings = {
		keymaps = {
			visual = "gs", -- use gs instead of s to avoid conflict with leap/flash
		},
	},
}

return opts
