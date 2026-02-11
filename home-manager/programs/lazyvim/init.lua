require("config.options")
require("config.lazy")
require("config.keymaps")

-- lua configs from nixvim
local nixvim_dir = vim.fn.stdpath("config") .. "/lua/nixvim"

for file in vim.fs.dir(nixvim_dir) do
  if file:match("%.lua$") then
    require("nixvim." .. file:gsub("%.lua$", ""))
  end
end
