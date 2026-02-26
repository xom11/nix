-- docs: https://github.com/CopilotC-Nvim/CopilotChat.nvim/
vim = vim
local opts = {}

-- Keymaps
local map = vim.keymap.set
map("n", "<leader>cc", "<CMD>CopilotChatToggle<CR>", { silent = true, desc = "Copilot Chat: toggle" })
map('v', '<leader>cc', function()
  local chat = require("CopilotChat")
  if chat.chat and chat.chat:visible() then
    chat.close()
  else
    chat.open({
      selection = require("CopilotChat.select").visual,
    })
  end
end, { desc = "CopilotChat: toggle with selection" })

return {
  opts = opts,
}
