vim.pack.add({ { src = "https://github.com/stevearc/conform.nvim" } }, { load = true, confirm = false })

local opts = {
	notify_on_error = true,
	formatters_by_ft = {
		["_"] = { "trim_whitespace" },
		bash = { "shfmt" },
		css = { "prettierd", "prettier", stop_after_first = true },
		html = { "prettierd", "prettier", stop_after_first = true },
		javascript = { "prettierd", "prettier", stop_after_first = true },
		javascriptreact = { "prettierd", "prettier", stop_after_first = true },
		json = { "prettierd" },
		lua = { "stylua" },
		markdown = { "prettierd", "prettier", stop_after_first = true },
		nix = { "alejandra" },
		python = { "black" },
		rust = { "rustfmt" },
		scss = { "prettierd", "prettier", stop_after_first = true },
		sh = { "shfmt" },
		toml = { "taplo" },
		typescript = { "prettierd", "prettier", stop_after_first = true },
		typescriptreact = { "prettierd", "prettier", stop_after_first = true },
		-- yamllint used to be first here, but it is a linter, not a conform
		-- formatter -- conform skipped it and fell through to yamlfmt anyway.
		yaml = { "yamlfmt" },
	},
	-- ps1 = { "psscriptanalyzer" } lived here with a custom `pwsh` formatter, but
	-- pwsh is not on nvim's PATH, so it could only ever fail. Add `powershell` to
	-- home.packages in default.nix if you want it back.
	format_on_save = false,
}

require("conform").setup(opts)

local map = vim.keymap.set
map("n", "<leader>lf", function()
	require("conform").format({
		lsp_format = "fallback",
		async = false,
		timeout_ms = 1000,
	})
end, { silent = true, desc = "Format file" })
