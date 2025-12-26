return {
    {
        "christoomey/vim-tmux-navigator",
        config = function()
            vim.keymap.set('n', 'C-h', ':TmuxNavigateLeft<CR>')
            vim.keymap.set('n', 'C-j', ':TmuxNavigateDown<CR>')
            vim.keymap.set('n', 'C-k', ':TmuxNavigateUp<CR>')
            vim.keymap.set('n', 'C-l', ':TmuxNavigateRight<CR>')
        end,
    },

    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        },
        keys = {
            {
            "<leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "Buffer Local Keymaps (which-key)",
            },
        },
    },

    {
      "okuuva/auto-save.nvim",
      version = '^1.0.0', -- see https://devhints.io/semver, alternatively use '*' to use the latest tagged release
      cmd = "ASToggle", -- optional for lazy loading on command
      event = { "InsertLeave", "TextChanged" }, -- optional for lazy loading on trigger events
      opts = {
        -- your config goes here
        -- or just leave it empty :)
      },
    },
}
