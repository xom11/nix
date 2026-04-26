-- Theme
vim.pack.add({ { src = "https://github.com/catppuccin/nvim" } }, { load = true })
vim.cmd.colorscheme("catppuccin")

-- Dependencies
vim.pack.add({ { src = "https://github.com/nvim-tree/nvim-web-devicons" } }, { load = true })
require("nvim-web-devicons").setup({})
vim.pack.add({ { src = "https://github.com/nvim-lua/plenary.nvim" } }, { load = true })
vim.pack.add({ { src = "https://github.com/MunifTanjim/nui.nvim" } }, { load = true })

-- Snippets
vim.pack.add({ { src = "https://github.com/rafamadriz/friendly-snippets" } }, { load = true })
vim.pack.add({ { src = "https://github.com/L3MON4D3/LuaSnip" } }, { load = true })
require("luasnip.loaders.from_vscode").lazy_load()

-- Comment
vim.pack.add({ { src = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring" } }, { load = true })
vim.pack.add({ { src = "https://github.com/numToStr/Comment.nvim" } }, { load = true })
require("Comment").setup({
	pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
})

-- Editor
vim.pack.add({ { src = "https://github.com/christoomey/vim-tmux-navigator" } }, { load = true })
vim.pack.add({ { src = "https://github.com/windwp/nvim-autopairs" } }, { load = true })
require("nvim-autopairs").setup({})
vim.pack.add({ { src = "https://github.com/mg979/vim-visual-multi" } }, { load = true })
vim.pack.add({ { src = "https://github.com/okuuva/auto-save.nvim" } }, { load = true })
require("auto-save").setup({})

-- UI
vim.pack.add({ { src = "https://github.com/nvim-lualine/lualine.nvim" } }, { load = true })
require("lualine").setup({})
vim.pack.add({ { src = "https://github.com/SmiteshP/nvim-navic" } }, { load = true })
require("nvim-navic").setup({ lsp = { auto_attach = true } })
vim.pack.add({ { src = "https://github.com/utilyre/barbecue.nvim" } }, { load = true })
require("barbecue").setup({})
require("plugins.snacks")
vim.pack.add({ { src = "https://github.com/folke/noice.nvim" } }, { load = true })
require("noice").setup({
	notify = {
		view = "snacks",
	},
})
vim.pack.add({ { src = "https://github.com/catgoose/nvim-colorizer.lua" } }, { load = true })
require("colorizer").setup({})
vim.pack.add({ { src = "https://github.com/folke/which-key.nvim" } }, { load = true })
require("which-key").setup({})

-- Tools
vim.pack.add({ { src = "https://github.com/tpope/vim-dadbod" } }, { load = true })
vim.pack.add({ { src = "https://github.com/kristijanhusak/vim-dadbod-ui" } }, { load = true })
vim.pack.add({ { src = "https://github.com/kristijanhusak/vim-dadbod-completion" } }, { load = true })

-- Auto-load all plugin configs
local source = debug.getinfo(1, "S").source:sub(2)
local dir = vim.fn.fnamemodify(source, ":h")
for _, file in ipairs(vim.fn.glob(dir .. "/*.lua", false, true)) do
	local name = vim.fn.fnamemodify(file, ":t:r")
	if name ~= "init" then
		require("plugins." .. name)
	end
end
