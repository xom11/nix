return {
	opts = {
		background_colour = "#000000",
		-- timeout = 3000,
	},

	config = function(_, opts)
		local notify = require("notify")
		notify.setup(opts)
		vim.notify = notify

		-- Show notification when starting and stopping macro recording
		vim.api.nvim_create_autocmd("RecordingEnter", {
			callback = function()
				local msg = "🔴 Recording @" .. vim.fn.reg_recording()
				vim.notify(msg, vim.log.levels.INFO, {
					title = "Macro",
					timeout = false,
				})
			end,
		})

		vim.api.nvim_create_autocmd("RecordingLeave", {
			callback = function()
				-- Dismiss the previous notification
				notify.dismiss({ pending = true, silent = true })

				vim.notify("Recording stopped", vim.log.levels.INFO, {
					title = "Macro",
					timeout = 2000,
				})
			end,
		})
	end,
}
