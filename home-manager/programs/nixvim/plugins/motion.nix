{
  config,
  ckModule,
  ...
}:
# Keymap Tab (cmp.nix)
ckModule config ./..
{
  programs.nixvim.plugins = {
    nvim-surround = {
      enable = true;
      settings = {
        keymaps = {
          visual = "gs"; # use gs instead of s to avoid conflict with leap/flash
        };
      };
    };
    leap = {
      enable = false;
      luaConfig.post = ''
        local map = vim.keymap.set
        map({'n', 'x', 'o'}, 's', '<Plug>(leap)')
        map('n',             'S', '<Plug>(leap-from-window)')
      '';
    };

    # https://nix-community.github.io/nixvim/plugins/flash/index.html#flash
    # https://github.com/folke/flash.nvim/
    flash = {
      enable = true;
      luaConfig.post = ''
        local map = vim.keymap.set
        -- x visual, o operator (d, y, etc.), c command-line /?
        -- treesitter : jumpping in code blocks
        -- map gs to resolve conficts with nvim-surround
        map({'n', 'x', 'o'}, 's', function() require("flash").jump() end, { desc = "Flash" })
        map({'n', 'x', 'o'}, 'S', function() require("flash").treesitter() end, { desc = "Flash Treesitter" })
        map({'o'}, 'r', function() require("flash").remote() end, { desc = "Remote Flash" })
        map({'o', 'x'}, 'R', function() require("flash").treesitter_search() end, { desc = "Treesitter Search" })
        map({'c'}, '<c-s>', function() require("flash").toggle() end, { desc = "Toggle Flash Search" })
        -- Guilded Flash jump
        -- f + word + f f f to jump forward
        -- r for forward in operator mode d + r to delete to the next occurrence
      '';
      settings = {
        jump = {
          # Automatically jump when there is only one match
          autojump = false;
          # Clear highlight after jump
          nohlsearch = true;
        };
      };
    };
  };
}
