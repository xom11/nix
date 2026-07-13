-- Pinned to `main`: the branch rewrote the plugin. setup() now only reads
-- `install_dir`, there is no highlight module, and parsers are installed
-- explicitly -- `auto_install` is not a real option and gets dropped silently.
vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
}, { load = true })

-- Folds
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99

-- kanata layouts are s-expressions
vim.filetype.add({
	extension = { kbd = "scheme" },
})

require("nvim-treesitter").setup({})

local ensure = {
	"astro",
	"bash",
	"c",
	"css",
	"diff",
	"dockerfile",
	"git_config",
	"gitcommit",
	"gitignore",
	"go",
	"gomod",
	"html",
	"javascript",
	"json",
	"lua",
	"luadoc",
	"markdown",
	"markdown_inline",
	"nix",
	"php",
	"python",
	"query",
	"regex",
	"rust",
	"scheme",
	"toml",
	"tsx",
	"typescript",
	"vim",
	"vimdoc",
	"yaml",
}

local installed = require("nvim-treesitter.config").get_installed("parsers")
local missing = vim.tbl_filter(function(lang)
	return not vim.list_contains(installed, lang)
end, ensure)
if #missing > 0 then
	require("nvim-treesitter").install(missing)
end

-- Highlighting is Neovim's, not the plugin's: nothing starts it for us.
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
	end,
})
