{
  config,
  ckModule,
  ...
}:
ckModule config ./.
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
        -- Navigation
        vim.keymap.set('n', ']h', '<cmd>Gitsigns next_hunk<CR>', { desc = "Next hunk" })
        vim.keymap.set('n', '[h', '<cmd>Gitsigns prev_hunk<CR>', { desc = "Prev hunk" })
        -- Actions (Hunks)
        vim.keymap.set({'n', 'v'}, '<leader>hs', '<cmd>Gitsigns stage_hunk<CR>', { desc = "Stage hunk" })
        vim.keymap.set({'n', 'v'}, '<leader>hr', '<cmd>Gitsigns reset_hunk<CR>', { desc = "Reset hunk" })
        -- Actions (Buffer)
        vim.keymap.set('n', '<leader>hS', '<cmd>Gitsigns stage_buffer<CR>', { desc = "Stage buffer" })
        vim.keymap.set('n', '<leader>hR', '<cmd>Gitsigns reset_buffer<CR>', { desc = "Reset buffer" })
        -- Blame
        vim.keymap.set('n', '<leader>hb', '<cmd>lua require\'gitsigns\'.blame_line({full = true})<CR>', { desc = "Blame line" })
        vim.keymap.set('n', '<leader>hB', '<cmd>Gitsigns toggle_current_line_blame<CR>', { desc = "Toggle line blame" })
        -- Text object
        vim.keymap.set({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = "Gitsigns select hunk" })
        -- Preview
        vim.keymap.set('n', '<leader>hp', '<cmd>Gitsigns preview_hunk<CR>', { desc = "Preview hunk" })
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
