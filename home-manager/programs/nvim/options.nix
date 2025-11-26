{
  config,
  ckModule,
  ...
}:
ckModule config ./. {
  programs.nixvim = {
    globals.mapleader = " ";
    clipboard.register = "unnamedplus";
    colorschemes.catppuccin.enable = true;

    opts = {
      expandtab = true;
      tabstop = 2;
      softtabstop = 2;
      shiftwidth = 2;

      number = false;
      relativenumber = false;

      # Enable more colors (24-bit)
      termguicolors = true;

      # Have a better completion experience
      completeopt = [
        "menuone"
        "noselect"
        "noinsert"
      ];

      # Enable mouse
      mouse = "a";

      list = true;
      # NOTE: .__raw here means that this field is raw lua code
      listchars.__raw = "{ tab = '» ', trail = '·', nbsp = '␣' }";

      # Save undo history
      undofile = true;
      swapfile = true;
      backup = false;
      autoread = true;

      # Highlight the current line for cursor
      cursorline = true;

      # Show line and column when searching
      ruler = true;

      # Start scrolling when the cursor is X lines away from the top/bottom
      scrolloff = 5;
    };

    diagnostics = {
      update_in_insert = true;
      severity_sort = true;
      float = {
        border = "rounded";
      };
      jump = {
        severity.__raw = "vim.diagnostic.severity.WARN";
      };
    };

  };
}
