local opts = {
	-- add any opts here
	-- this file can contain specific instructions for your project
	instructions_file = "avante.md",
	-- for example
	provider = "gemini",
	providers = {
		gemini = {
			model = "gemini-2.5-flash",
			api_key_name = "GEMINI_KEY",
		},
	},
	behaviour = {
		enable_fastapply = true,
	},
	windows = {
		position = "right",
		width = 50,
	},
}

require("avante").setup(opts)
