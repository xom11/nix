
-- Set workspace path (works on Windows, macOS, and Linux)
local workspace_path = vim.fn.expand("~/Documents/obsidian")

-- Ensure workspace directory exists
if vim.fn.isdirectory(workspace_path) == 0 then
  vim.fn.mkdir(workspace_path, "p")
end

local opts = {
  -- Workspace configuration
  workspaces = {
    {
      name = "notes",
      path = workspace_path,
    },
  },

  -- Daily notes
  daily_notes = {
    folder = "daily",
  },

  -- Completion with nvim-cmp
  completion = {
    nvim_cmp = true,
    min_chars = 2,
  },

  -- Use new command format (Obsidian backlinks instead of ObsidianBacklinks)
  legacy_commands = false,

  -- UI enable
  ui = {
    enable = true,
  },
}

return {
  opts = opts,
}
