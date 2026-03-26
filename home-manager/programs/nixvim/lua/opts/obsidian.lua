local M = {}

M.opts = {
  -- Workspace configuration
  workspaces = {
    {
      name = "notes",
      path = "~/Documents/note",
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

return M
