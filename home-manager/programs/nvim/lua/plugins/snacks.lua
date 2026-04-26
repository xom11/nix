vim.pack.add({ { src = "https://github.com/folke/snacks.nvim" } }, { load = true })
require("snacks").setup({
	notifier = {
		enabled = true,
	},
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
