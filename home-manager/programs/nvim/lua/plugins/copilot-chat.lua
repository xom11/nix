vim.pack.add({ { src = "https://github.com/CopilotC-Nvim/CopilotChat.nvim" } }, { load = true })
-- docs: https://github.com/CopilotC-Nvim/CopilotChat.nvim/
vim = vim
local opts = {
  prompts = {
    Grammar = {
      system_prompt = "You are a helpful assistant that corrects grammar mistakes in the given text.",
      prompt = "Correct the grammar mistakes in the following text:\n\n{input}",
    }
  }
}
vim.g.copilot_no_tab_map = true
vim.keymap.set('i', '<S-Tab>', 'copilot#Accept("\\<S-Tab>")', { expr = true, replace_keycodes = false })
require("CopilotChat").setup(opts)
