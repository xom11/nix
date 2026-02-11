return {
  "akinsho/toggleterm.nvim",
  version = "*",
  opts = function()
    local shell_cmd = vim.o.shell

    if vim.fn.has("win32") == 1 then
      if vim.fn.executable("pwsh") == 1 then
        shell_cmd = "pwsh"
      else
        shell_cmd = "powershell"
      end
    end

    return {
      shell = shell_cmd,
      direction = "float",
      open_mapping = [[<a-t>]],
      float_opts = {
        border = "curved",
        width = function()
          return math.floor(vim.o.columns * 0.8)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.8)
        end,
      },
    }
  end,
}
