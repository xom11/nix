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
}