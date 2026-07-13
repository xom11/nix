vim.pack.add({ { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" } }, { load = true, confirm = false })

local opts = {
  -- "Avante" was in here, but avante.nvim is not installed.
  file_types = { "markdown" },
}

require("render-markdown").setup(opts)
