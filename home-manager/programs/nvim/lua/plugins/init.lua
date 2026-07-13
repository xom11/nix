-- Theme
-- Explicit `name`: vim.pack derives it from the last URL segment, so this repo
-- would otherwise install into a directory literally called "nvim".
vim.pack.add({ { src = "https://github.com/catppuccin/nvim", name = "catppuccin" } }, { load = true, confirm = false })
vim.cmd.colorscheme("catppuccin")

-- Dependencies
vim.pack.add({ { src = "https://github.com/nvim-tree/nvim-web-devicons" } }, { load = true, confirm = false })
require("nvim-web-devicons").setup({})
vim.pack.add({ { src = "https://github.com/nvim-lua/plenary.nvim" } }, { load = true, confirm = false })
vim.pack.add({ { src = "https://github.com/MunifTanjim/nui.nvim" } }, { load = true, confirm = false })

-- Snippets
vim.pack.add({ { src = "https://github.com/rafamadriz/friendly-snippets" } }, { load = true, confirm = false })
vim.pack.add({ { src = "https://github.com/L3MON4D3/LuaSnip" } }, { load = true, confirm = false })
require("luasnip.loaders.from_vscode").lazy_load()

-- Comment: none. Core owns gc/gcc/gc-textobject, and vim._comment already walks
-- the treesitter LanguageTree to pick the commentstring at the cursor -- so JSX
-- inside a .tsx comments as {/* */} with no plugin. That is the whole job
-- Comment.nvim (archived) + nvim-ts-context-commentstring were doing here.
-- The one thing core lacks is blockwise gb/gbc.

-- Editor
vim.pack.add({ { src = "https://github.com/christoomey/vim-tmux-navigator" } }, { load = true, confirm = false })
vim.pack.add({ { src = "https://github.com/windwp/nvim-autopairs" } }, { load = true, confirm = false })
require("nvim-autopairs").setup({})
vim.pack.add({ { src = "https://github.com/mg979/vim-visual-multi" } }, { load = true, confirm = false })
vim.pack.add({ { src = "https://github.com/okuuva/auto-save.nvim" } }, { load = true, confirm = false })
require("auto-save").setup({
	-- Never autosave *.age: writing re-runs the encrypt step in extras/age-edit.lua,
	-- so a stray keystroke would rewrite the secret on every InsertLeave.
	condition = function(buf)
		return not vim.api.nvim_buf_get_name(buf):match("%.age$") and vim.bo[buf].buftype ~= "acwrite"
	end,
})

-- UI
vim.pack.add({ { src = "https://github.com/SmiteshP/nvim-navic" } }, { load = true, confirm = false })
require("nvim-navic").setup({ lsp = { auto_attach = true } })

-- barbecue.nvim (abandoned 2024-08) was only a winbar wrapper around navic.
-- lualine draws the same breadcrumb, and it was already here on setup({}).
vim.pack.add({ { src = "https://github.com/nvim-lualine/lualine.nvim" } }, { load = true, confirm = false })
require("lualine").setup({
	winbar = {
		lualine_c = {
			{
				function()
					return require("nvim-navic").get_location()
				end,
				cond = function()
					return require("nvim-navic").is_available()
				end,
			},
		},
	},
})

require("plugins.snacks")
vim.pack.add({ { src = "https://github.com/folke/noice.nvim" } }, { load = true, confirm = false })
require("noice").setup({
	notify = {
		view = "snacks",
	},
})
vim.pack.add({ { src = "https://github.com/catgoose/nvim-colorizer.lua" } }, { load = true, confirm = false })
-- setup({}) means filetypes = { "*" }: it attached a colour parser to every
-- buffer, including big files with no colours in them.
require("colorizer").setup({
	filetypes = {
		"css",
		"scss",
		"html",
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"svelte",
		"vue",
		"astro",
		"lua",
		"nix",
		"toml",
		"yaml",
	},
	lazy_load = true,
})
vim.pack.add({ { src = "https://github.com/folke/which-key.nvim" } }, { load = true, confirm = false })
require("which-key").setup({})

-- Auto-load all plugin configs. pcall so one broken file (or a plugin whose
-- clone failed) doesn't abort the loop and take every later config with it --
-- same policy as extras/init.lua.
local source = debug.getinfo(1, "S").source:sub(2)
local dir = vim.fn.fnamemodify(source, ":h")
for _, file in ipairs(vim.fn.glob(dir .. "/*.lua", false, true)) do
	local name = vim.fn.fnamemodify(file, ":t:r")
	if name ~= "init" then
		local ok, err = pcall(require, "plugins." .. name)
		if not ok then
			vim.notify("Error loading plugins." .. name .. "\n" .. tostring(err), vim.log.levels.ERROR)
		end
	end
end
