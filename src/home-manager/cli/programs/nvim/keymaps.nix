{ ... }:

{
  programs = {
    nixvim = {
      keymaps = [
        {
          key = "<leader>lf";
          action = "<cmd>lua require('conform').format({ lsp_fallback = true, async = false, timeout_ms = 500 })<CR>";

          options = {
            silent = true;
          };
        }
        {
          key = "<leader>t";
          action = "<CMD>Neotree toggle<NL>";
        }
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
        {
          key = "<C-a>";
          action = "ggVG";
        }
        {
          key = "gd";
          mode = "n";
          action = "<cmd>lua vim.lsp.buf.definition()<cr>";
        }
	
      ];
    };
  };
}
