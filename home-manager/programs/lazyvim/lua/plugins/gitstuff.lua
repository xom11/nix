return {
  -- Gitsigns
  {
    "lewis6991/gitsigns.nvim",
    opts = require("opts.gitsigns"),
  },

  -- Diffview
  {
    "sindrets/diffview.nvim",
  },

  -- Lazygit
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
}
