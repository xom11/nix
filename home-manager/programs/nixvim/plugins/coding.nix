{
  config,
  ckModule,
  pkgs,
  ...
}:
ckModule config ./..
{
  # PART: telescope
  programs.nixvim.plugins.telescope = {
    enable = true;
    settings = {__raw = "require('opts.telescope')";};
    extensions = {
      ui-select.enable = true;
      frecency = {
        enable = true;
        # Fix issue https://github.com/nvim-telescope/telescope-frecency.nvim/issues/270
        settings.db_safe_mode = false;
        # Fix issue https://github.com/nvim-telescope/telescope-frecency.nvim/issues/105
        settings.db_validate_threshold = 1;
      };
      fzf-native.enable = true;
      file-browser = {
        enable = true;
        settings.hidden = true;
        settings.depth = 9999999999;
        settings.auto_depth = true;
      };
    };
  };
  # PART: lsp
  programs.nixvim.plugins.cmp-nvim-lsp = {
    enable = true;
  };

  programs.nixvim.plugins.cmp = {
    enable = true;
    autoEnableSources = true;
    settings = {__raw = "require('opts.cmp').opts";};
    cmdline = {
      ":" = {
        mapping = {
          __raw = "require('opts.cmp').cmdline[':'].mapping";
        };
        sources = [
          {name = "path";}
          {name = "cmdline";}
        ];
      };
    };
  };
  # PART: conform-nvim
  programs.nixvim.plugins.conform-nvim = {
    enable = true;
    settings = {__raw = "require('opts.conform')";};
  };
  home.packages = with pkgs; [
    black
    shfmt
    stylua
    alejandra
    prettierd
    yamllint
    yamlfmt
    taplo
  ];
  # PART: treesitter
  programs.nixvim = {
    filetype.extension.kbd = "lisp";
    extraPackages = with pkgs; [
      tree-sitter
    ];
  };
  programs.nixvim.plugins.treesitter = {
    enable = true;
    grammarPackages = pkgs.vimPlugins.nvim-treesitter.allGrammars;
    settings = {
      auto_install = false;
      highlight.enable = true;
      indent.enable = true;
    };
  };
}
