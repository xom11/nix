local M = {}

M.opts = {
  workspaces = {
    {
      name = "notes",
      path = "~/Documents/note",
    },
  },

  -- Daily notes
  daily_notes = {
    folder = "daily",
    date_format = "%Y-%m-%d",
    template = nil,
  },

  -- Completion
  completion = {
    nvim_cmp = true,
    min_chars = 2,
  },

  -- Note ID generation
  note_id_func = function(title)
    local suffix = ""
    if title ~= nil then
      suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
    else
      for _ = 1, 4 do
        suffix = suffix .. string.char(math.random(65, 90))
      end
    end
    return tostring(os.time()) .. "-" .. suffix
  end,

  -- Note path function
  note_path_func = function(spec)
    local path = spec.dir / tostring(spec.id)
    return path:with_suffix(".md")
  end,

  -- Disable frontmatter
  disable_frontmatter = false,

  -- Templates
  templates = {
    folder = "templates",
    date_format = "%Y-%m-%d",
    time_format = "%H:%M",
  },

  -- Mappings
  mappings = {
    -- Follow link under cursor
    ["gf"] = {
      action = function()
        return require("obsidian").util.gf_passthrough()
      end,
      opts = { noremap = false, expr = true, buffer = true },
    },
    -- Toggle checkbox
    ["<leader>ch"] = {
      action = function()
        return require("obsidian").util.toggle_checkbox()
      end,
      opts = { buffer = true },
    },
    -- Smart action
    ["<cr>"] = {
      action = function()
        return require("obsidian").util.smart_action()
      end,
      opts = { buffer = true, expr = true },
    },
  },

  -- UI options
  ui = {
    enable = true,
    update_debounce = 200,
    checkboxes = {
      [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
      ["x"] = { char = "", hl_group = "ObsidianDone" },
      [">"] = { char = "", hl_group = "ObsidianRightArrow" },
      ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
    },
    bullets = { char = "•", hl_group = "ObsidianBullet" },
    external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
    reference_text = { hl_group = "ObsidianRefText" },
    highlight_text = { hl_group = "ObsidianHighlightText" },
    tags = { hl_group = "ObsidianTag" },
    block_ids = { hl_group = "ObsidianBlockID" },
    hl_groups = {
      ObsidianTodo = { bold = true, fg = "#f78c6c" },
      ObsidianDone = { bold = true, fg = "#89ddff" },
      ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
      ObsidianTilde = { bold = true, fg = "#ff5370" },
      ObsidianBullet = { bold = true, fg = "#89ddff" },
      ObsidianRefText = { underline = true, fg = "#c792ea" },
      ObsidianExtLinkIcon = { fg = "#c792ea" },
      ObsidianTag = { italic = true, fg = "#89ddff" },
      ObsidianBlockID = { italic = true, fg = "#89ddff" },
      ObsidianHighlightText = { bg = "#75662e" },
    },
  },

  -- Attachments
  attachments = {
    img_folder = "assets/imgs",
  },

  -- Picker
  picker = {
    name = "telescope.nvim",
    mappings = {
      new = "<C-x>",
      insert_link = "<C-l>",
    },
  },

  -- Follow URL
  follow_url_func = function(url)
    vim.fn.jobstart({ "open", url })
  end,
}

return M
