vim.pack.add({ { src = "https://github.com/HakonHarnes/img-clip.nvim" } }, { load = true })
-- https://github.com/HakonHarnes/img-clip.nvim
local opts = {
	default = {
		embed_image_as_base64 = false,
		prompt_for_file_name = false,
		drag_and_drop = {
			enabled = false,
		},
		use_absolute_path = true,
	},
}

require("img-clip").setup(opts)
