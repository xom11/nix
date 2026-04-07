{
  config,
  ckModule,
  pkgs,
  ...
}:
ckModule config ./..
{
  programs.nixvim.plugins = {
    copilot-lua = {
      enable = true;
      settings = {__raw = "require('opts.copilot-lua').opts";};
    };
    copilot-chat = {
      enable = true;
      settings = {__raw = "require('opts.copilot-chat').opts";};
    };
    # avante = {
    #   enable = true;
    #   settings = {__raw = "require('opts.avante').opts";};
    # };
    img-clip = {
      enable = true;
      settings = {__raw = "require('opts.img-clip')";};
    };
    # obsidian = {
    #   enable = true;
    #   settings = {__raw = "require('opts.obsidian').opts";};
    # };
    telescope = {
      enable = true;
      extensions = {
        ui-select.enable = true;
        frecency = {
          enable = true;
          settings.db_safe_mode = false;
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
      settings = {
        defaults = {
          __raw = "require('opts.telescope').opts.defaults";
        };
      };
    };
    cmp-nvim-lsp = {
      enable = true;
    };
    cmp = {
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
    conform-nvim = {
      enable = true;
      settings = {__raw = "require('opts.conform')";};
    };
    treesitter = {
      enable = true;
      grammarPackages = pkgs.vimPlugins.nvim-treesitter.allGrammars;
      settings = {__raw = "require('opts.treesitter').opts";};
      luaConfig.post = "require('opts.treesitter-textobjects')";
    };
    treesitter-textobjects = {
      enable = true;
    };
    vim-dadbod = {
      enable = true;
    };
    vim-dadbod-ui = {
      enable = true;
    };
    vim-dadbod-completion = {
      enable = true;
    };
    gitsigns = {
      enable = true;
      settings = {__raw = "require('opts.gitsigns')";};
    };
    neo-tree = {
      enable = true;
      settings = {__raw = "require('opts.neotree')";};
    };
    todo-comments = {
      enable = true;
      settings = {__raw = "require('opts.todo-comments')";};
    };
    harpoon = {
      enable = true;
    };
    nvim-surround = {
      enable = true;
      settings = {__raw = "require('opts.nvim-surround')";};
    };
    flash = {
      enable = true;
      settings = {__raw = "require('opts.flash')";};
    };
    auto-save.enable = true;
    comment = {
      enable = true;
      settings = {
        pre_hook = "require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()";
      };
    };
    ts-context-commentstring.enable = true;
    friendly-snippets.enable = true;
    luasnip.enable = true;
    cmp_luasnip.enable = true;
    nvim-autopairs.enable = true;
    tmux-navigator.enable = true;
    visual-multi.enable = true;
    web-devicons.enable = true;
    toggleterm = {
      enable = true;
      settings = {__raw = "require('opts.toggleterm')";};
    };
    which-key = {
      enable = true;
    };
    lualine = {
      enable = true;
    };
    render-markdown = {
      enable = true;
      settings = {__raw = "require('opts.render-markdown').opts";};
    };
    dashboard.enable = true;
    colorizer.enable = true;
    noice.enable = true;
    image.enable = true;
    barbecue.enable = true;
    notify = {
      enable = true;
      luaConfig.post = ''
        local t = require('opts.nvim-notify')
        t.config(nil, t.opts)
      '';
      settings = {__raw = "require('opts.nvim-notify').opts";};
    };
    transparent = {
      enable = true;
      luaConfig.post = ''
        local t = require('opts.transparent')
        t.config(nil, t.opts)
      '';
      settings = {__raw = "require('opts.transparent').opts";};
    };
  };

  home.packages = with pkgs; [
    # conform formatters
    black
    shfmt
    stylua
    alejandra
    prettierd
    yamllint
    yamlfmt
    taplo

    # lsp
    nixd
  ];
}
