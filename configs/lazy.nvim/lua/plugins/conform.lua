return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	dependencies = {
		"williamboman/mason.nvim",
	},
	config = function()
		local conform = require("conform")

		conform.setup({
			notify_on_error = true,
			formatters_by_ft = {
				html = { "prettierd", "prettier", stop_after_first = true },
				css = { "prettierd", "prettier", stop_after_first = true },
				scss = { "prettierd", "prettier", stop_after_first = true },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				markdown = { "prettierd", "prettier", stop_after_first = true },
				yaml = { "yamllint", "yamlfmt", stop_after_first = true },
				json = { "prettierd" },
				nix = { "alejandra" },
				lua = { "stylua" },
				python = { "black" },
				rust = { "rustfmt" },
				sh = { "shfmt" },
				bash = { "shfmt" },
				["_"] = { "trim_whitespace" },
			},
			format_on_save = false,
		})

		vim.keymap.set("n", "<leader>lf", function()
			conform.format({
				lsp_format = "fallback",
				async = false,
				timeout_ms = 1000,
			})
		end, { silent = true, desc = "Format file" })
	end,
}
