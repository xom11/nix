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
		ps1 = { "psscriptanalyzer" },
		python = { "black" },
		rust = { "rustfmt" },
		scss = { "prettierd", "prettier", stop_after_first = true },
		sh = { "shfmt" },
		toml = { "taplo" },
		typescript = { "prettierd", "prettier", stop_after_first = true },
		typescriptreact = { "prettierd", "prettier", stop_after_first = true },
		yaml = { "yamllint", "yamlfmt", stop_after_first = true },
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
