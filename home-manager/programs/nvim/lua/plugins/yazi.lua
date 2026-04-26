vim.pack.add({ { src = "https://github.com/mikavilpas/yazi.nvim" } }, { load = true })

require("yazi").setup({
	open_for_directories = false,
	keymaps = {
		show_help = "<f1>",
	},
})

local map = vim.keymap.set
map({ "n", "v" }, "<leader>ee", "<CMD>Yazi<CR>", { desc = "Yazi: open at current file" })
map("n", "<leader>ec", "<CMD>Yazi cwd<CR>", { desc = "Yazi: open in cwd" })
map("n", "<leader>er", "<CMD>Yazi toggle<CR>", { desc = "Yazi: resume last session" })
