-- Pinned to `main`: the branch rewrote the plugin. setup() now only reads
-- `install_dir`, there is no highlight module, and parsers are installed
-- explicitly -- `auto_install` is not a real option and gets dropped silently.
vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
}, { load = true, confirm = false })

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

-- gitcommit is dropped on Windows. Its generated parser sends MSVC into a pathological
-- compile: one core pinned, still running after ten minutes, never producing a .so. The
-- other thirty here build in seconds on the same toolchain. Because install() re-runs for
-- whatever is still missing, every single nvim launch left another doomed cl.exe grinding
-- in the background -- the failure was not the error line, it was the CPU.
-- clang builds it fine on macOS and Linux, so this stays platform-specific rather than a
-- deletion from the list.
if vim.fn.has("win32") == 1 then
	ensure = vim.tbl_filter(function(lang)
		return lang ~= "gitcommit"
	end, ensure)
end

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
