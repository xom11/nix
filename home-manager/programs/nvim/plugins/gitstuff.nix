{
  config,
  ckModule,
  ...
}:
ckModule config ./..
{
  programs.nixvim.plugins = {
    gitsigns = {
      enable = true;
      settings = {
        current_line_blame = true;
        current_line_blame_opts = {
          delay = 500;
        };
      };
      luaConfig.post = ''
        local map = vim.keymap.set
        -- Navigation
        map('n', ']h', '<cmd>Gitsigns next_hunk<CR>', { desc = "Next hunk" })
        vim.keymap.set('n', '[h', '<cmd>Gitsigns prev_hunk<CR>', { desc = "Prev hunk" })
        -- Actions (Hunks)
        map({'n', 'v'}, '<leader>hs', '<cmd>Gitsigns stage_hunk<CR>', { desc = "Stage hunk" })
        map({'n', 'v'}, '<leader>hr', '<cmd>Gitsigns reset_hunk<CR>', { desc = "Reset hunk" })
        -- Actions (Buffer)
        map('n', '<leader>hS', '<cmd>Gitsigns stage_buffer<CR>', { desc = "Stage buffer" })
        map('n', '<leader>hR', '<cmd>Gitsigns reset_buffer<CR>', { desc = "Reset buffer" })
        -- Blame
        map('n', '<leader>hb', '<cmd>lua require\'gitsigns\'.blame_line({full = true})<CR>', { desc = "Blame line" })
        map('n', '<leader>hB', '<cmd>Gitsigns toggle_current_line_blame<CR>', { desc = "Toggle line blame" })
        -- Text object
        map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = "Gitsigns select hunk" })
        -- Preview
        map('n', '<leader>hp', '<cmd>Gitsigns preview_hunk<CR>', { desc = "Preview hunk" })
      '';
    };

    # https://nix-community.github.io/nixvim/plugins/diffview/luaConfig.html
    # https://github.com/sindrets/diffview.nvim/
    diffview = {
      enable = true;
      luaConfig.post = ''
        vim.keymap.set('n', '<leader>hd', function()
          if next(require("diffview.lib").views) == nil then
            vim.cmd("DiffviewOpen")
          else
            vim.cmd("DiffviewClose")
          end
        end, { desc = "Toggle Diffview" })
      '';
    };


    lazygit = {
      enable = true;
    };
  };
}
