vim.pack.add({ { src = "https://github.com/folke/snacks.nvim" } }, { load = true, confirm = false })
require("snacks").setup({
	notifier = {
		enabled = true,
	},
	-- snacks.picker/explorer stay off -- telescope and neo-tree own that.
	-- These two are just free: bigfile turns off treesitter/LSP/syntax on huge
	-- files instead of hanging, quickfile paints the buffer before plugins load.
	bigfile = { enabled = true },
	quickfile = { enabled = true },
})

-- Macro recording notifications
vim.api.nvim_create_autocmd("RecordingEnter", {
	callback = function()
		vim.notify("Recording @" .. vim.fn.reg_recording(), vim.log.levels.INFO, { title = "Macro" })
	end,
})

vim.api.nvim_create_autocmd("RecordingLeave", {
	callback = function()
		Snacks.notifier.hide()
		vim.notify("Recording stopped", vim.log.levels.INFO, { title = "Macro" })
	end,
})
