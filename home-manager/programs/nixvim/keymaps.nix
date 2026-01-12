{
  config,
  ckModule,
  ...
}:
ckModule config ./.
{
  programs = {
    nixvim = {
      keymaps = [
        # Better indenting in visual mode
        {
          key = ">";
          mode = "v";
          action = ">gv";
        }
        {
          key = "<";
          mode = "v";
          action = "<gv";
        }
        # Move selected lines
        {
          key = "J";
          mode = "v";
          action = ":m '>+1<cr>gv=gv";
        }
        {
          key = "K";
          mode = "v";
          action = ":m '<-2<cr>gv=gv";
        }
        {
          key = "ga";
          action = "ggVG";
          options.desc = "Select all";
        }
        {
          key = "<leader>p";
          mode = "v";
          action = "\"_dP";
          options.desc = "Paste without overwriting clipboard";
        }
        {
          key = "<leader>yy";
          mode = "n";
          action = ":let @+ = expand('%:p')<cr>";
          options.desc = "Copy file path to clipboard";
        }
        {
          key = "<leader>yr";
          mode = "n";
          action = ":let @+ = expand('%')<CR>";
          options.desc = "Copy relative path to clipboard";
        }
        {
          key = "<leader>yf";
          mode = "n";
          action = ":let @+ = expand('%:t')<CR>";
          options.desc = "Copy filename to clipboard";
        }
        # Diagnostic keymaps
        {
          mode = "n";
          key = "<leader>ey";
          action.__raw = ''
            function()
              local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
              if #diagnostics > 0 then
                local message = diagnostics[1].message
                vim.fn.setreg("+", message)
                print("Copied diagnostic: " .. message)
              else
                print("No diagnostic at cursor")
              end
            end
          '';
          options = {
            noremap = true;
            silent = true;
            desc = "Copy diagnostic message to clipboard";
          };
        }
        {
          mode = "n";
          key = "<leader>en";
          action.__raw = "vim.diagnostic.goto_next";
          options = {
            desc = "Go to next error/diagnostic";
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>ep";
          action.__raw = "vim.diagnostic.goto_prev";
          options = {
            desc = "Go to previous error/diagnostic";
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>es";
          action.__raw = "vim.diagnostic.open_float";
          options = {
            desc = "Show diagnostic error message";
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>gg";
          action = "<cmd>LazyGit<CR>";
          options = {
            desc = "LazyGit (root dir)";
          };
        }
      ];
    };
  };
}
