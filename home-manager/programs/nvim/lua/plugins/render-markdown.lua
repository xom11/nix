vim.pack.add({ { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" } }, { load = true })

local opts = {
  file_types = { "markdown", "Avante" },
}

require("render-markdown").setup(opts)
