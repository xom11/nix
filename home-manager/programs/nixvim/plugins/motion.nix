{
  config,
  ckModule,
  ...
}:
# Keymap Tab (cmp.nix)
ckModule config ./..
{
  programs.nixvim.plugins = {
    # PART: todo-comments.nvim
    # https://github.com/folke/todo-comments.nvim/
    # Highlight and search for todo comments like TODO, HACK, BUG in your code
    todo-comments = {
      enable = true;
      settings = {
        highlight = {
          multiline = false;
        };
        keywords = {
          FIX = {
            alt = ["FIXME" "BUG" "FIXIT" "ISSUE"];
            color = "error";
            icon = " ";
          };
          HACK = {
            color = "warning";
            icon = " ";
          };
          NOTE = {
            alt = ["INFO"];
            color = "hint";
            icon = " ";
          };
          SECTION = {
            alt = ["CHAPTER" "PART"];
            icon = " ";
          };
          GUIDE = {
            alt = ["DOCS" "DOCUMENTATION"];
            icon = "󰉋 ";
          };
          PERF = {
            alt = ["OPTIM" "PERFORMANCE" "OPTIMIZE"];
            icon = " ";
          };
          TEST = {
            alt = ["TESTING" "PASSED" "FAILED"];
            color = "test";
            icon = "⏲ ";
          };
          TODO = {
            color = "info";
            icon = " ";
          };
          WARN = {
            alt = ["WARNING" "XXX"];
            color = "warning";
            icon = " ";
          };
        };
      };
      luaConfig.post = ''
        vim.keymap.set("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next Todo Comment" })
        vim.keymap.set("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Previous Todo Comment" })
      '';
    };

    # PART: harpoon
    # https://github.com/ThePrimeagen/harpoon/
    # mark files and quickly navigate between them
    harpoon = {
      enable = true;
    };

    # PART: nvim-surround
    # https://github.com/kylechui/nvim-surround?tab=readme-ov-file#rocket-usage
    # add, delete, change surroundings (parentheses, brackets, quotes, tags, etc.)
    nvim-surround = {
      enable = true;
      settings = {
        keymaps = {
          visual = "gs"; # use gs instead of s to avoid conflict with leap/flash
        };
      };
    };

    # PART: leap.nvim
    leap = {
      enable = false;
      luaConfig.post = ''
        local map = vim.keymap.set
        map({'n', 'x', 'o'}, 's', '<Plug>(leap)')
        map('n',             'S', '<Plug>(leap-from-window)')
      '';
    };

    # PART: flash.nvim
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
