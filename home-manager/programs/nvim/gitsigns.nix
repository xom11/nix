{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.modules.programs.nvim;
in
  lib.mkIf cfg.enable
  {
    programs.nixvim.plugins.gitsigns = {
      enable = true;
      settings = {
        current_line_blame = true;
        current_line_blame_opts = {
          delay = 500;
        };
      };
    };
    programs.nixvim.keymaps = [
        # Navigation
        { mode = "n"; key = "]h"; action = "<cmd>Gitsigns next_hunk<CR>"; options.desc = "Next hunk"; }
        { mode = "n"; key = "[h"; action = "<cmd>Gitsigns prev_hunk<CR>"; options.desc = "Prev hunk"; }

        # Actions (Hunks)
        { mode = ["n" "v"]; key = "<leader>hs"; action = "<cmd>Gitsigns stage_hunk<CR>"; options.desc = "Stage hunk"; }
        { mode = ["n" "v"]; key = "<leader>hr"; action = "<cmd>Gitsigns reset_hunk<CR>"; options.desc = "Reset hunk"; }

        # Actions (Buffer)
        { mode = "n"; key = "<leader>hS"; action = "<cmd>Gitsigns stage_buffer<CR>"; options.desc = "Stage buffer"; }
        { mode = "n"; key = "<leader>hR"; action = "<cmd>Gitsigns reset_buffer<CR>"; options.desc = "Reset buffer"; }

        # Blame
        { mode = "n"; key = "<leader>hb"; action = "<cmd>lua require'gitsigns'.blame_line({full = true})<CR>"; options.desc = "Blame line"; }
        { mode = "n"; key = "<leader>hB"; action = "<cmd>Gitsigns toggle_current_line_blame<CR>"; options.desc = "Toggle line blame"; }

        # Diff
        { mode = "n"; key = "<leader>hd"; action = "<cmd>Gitsigns diffthis<CR>"; options.desc = "Diff this"; }
        { mode = "n"; key = "<leader>hD"; action = "<cmd>Gitsigns diffthis ~<CR>"; options.desc = "Diff this ~"; }

        # Text object 
        { mode = ["o" "x"]; key = "ih"; action = ":<C-U>Gitsigns select_hunk<CR>"; options.desc = "Gitsigns select hunk"; }

        # Diffview Toggle 
        {
          mode = "n";
          key = "<leader>dv";
          action = ''
           <cmd>lua if next(require("diffview.lib").views) == nil then vim.cmd("DiffviewOpen") else vim.cmd("DiffviewClose") end<CR>
          '';
          options.desc = "Toggle Diffview";
        }
  ];
  }
