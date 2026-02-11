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
			-- log_level = vim.log.levels.DEBUG,
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
				ps1 = { "psscriptanalyzer" },
				python = { "black" },
				rust = { "rustfmt" },
				scss = { "prettierd", "prettier", stop_after_first = true },
				sh = { "shfmt" },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				yaml = { "yamllint", "yamlfmt", stop_after_first = true },
        toml = { "taplo" },
			},
			formatters = {
				psscriptanalyzer = {
					command = "pwsh",
					args = {
						"-NoProfile",
						"-NonInteractive",
						"-Command",
						[[
                $inputString = [Console]::In.ReadToEnd()
                if ([string]::IsNullOrWhiteSpace($inputString)) { exit 0 }
                $result = Invoke-Formatter -ScriptDefinition $inputString
                if ($result) { $result } else { $inputString }
            ]],
					},
					stdin = true,
				},
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
