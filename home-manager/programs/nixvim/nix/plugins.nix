{
  config,
  ckModule,
  pkgs,
  ...
}:
ckModule config ./..
{
  programs.nixvim.plugins = {
    # PART: copilot
    copilot-lua = {
      enable = true;
      settings = {__raw = "require('opts.copilot-lua').opts";};
    };
    # PART: copilot-chat
    copilot-chat = {
      enable = true;
      settings = {__raw = "require('opts.copilot-chat').opts";};
    };
    # PART: avante
    avante = {
      enable = true;
      settings = {__raw = "require('opts.avante').opts";};
    };
    # PART: telescope
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
    # PART: cmp-nvim-lsp
    cmp-nvim-lsp = {
      enable = true;
    };
    # PART: cmp
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
    # PART: conform-nvim
    conform-nvim = {
      enable = true;
      settings = {__raw = "require('opts.conform')";};
    };
    # PART: treesitter
    treesitter = {
      enable = true;
      grammarPackages = pkgs.vimPlugins.nvim-treesitter.allGrammars;
      settings = {__raw = "require('opts.treesitter').opts";};
      luaConfig.post = "require('opts.treesitter-textobjects')";
    };
    # PART: treesitter-textobjects
    treesitter-textobjects = {
      enable = true;
    };
    # PART: vim-dadbod
    vim-dadbod = {
      enable = true;
    };
    # PART: vim-dadbod-ui
    vim-dadbod-ui = {
      enable = true;
    };
    # PART: vim-dadbod-completion
    vim-dadbod-completion = {
      enable = true;
    };
    # PART: gitsigns
    gitsigns = {
      enable = true;
      settings = {__raw = "require('opts.gitsigns')";};
    };
    # PART: diffview
    diffview = {
      enable = true;
    };
    # PART: lazygit
    lazygit = {
      enable = true;
    };
    # PART: lsp
    lsp = {
      enable = true;
      servers = {
        pyright = {
          enable = true;
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "off";
                autoSearchPaths = true;
                useLibraryCodeForTypes = true;
              };
            };
          };
        };
        nixd.enable = true;
        jsonls.enable = true;
        yamlls.enable = true;
        marksman.enable = true;
        ts_ls.enable = true;
        cssls.enable = true;
        tailwindcss.enable = true;
        html.enable = true;
        astro.enable = true;
        phpactor.enable = true;
        svelte.enable = false;
        dockerls.enable = true;
        bashls.enable = true;
        clangd.enable = true;
        gopls.enable = true;
        lua_ls = {
          enable = true;
          settings.telemetry.enable = false;
        };
        emmet_language_server.enable = true;
        rust_analyzer = {
          enable = true;
          installRustc = true;
          installCargo = true;
        };
      };
      keymaps = {
        silent = true;
        lspBuf = {
          "<leader>rn" = {
            action = "rename";
            desc = "Rename";
          };
        };
      };
    };
    # PART: neo-tree
    neo-tree = {
      enable = true;
      settings = {__raw = "require('opts.neotree')";};
    };
    # PART: todo-comments
    todo-comments = {
      enable = true;
      settings = {__raw = "require('opts.todo-comments')";};
    };
    # PART: harpoon
    harpoon = {
      enable = true;
    };
    # PART: nvim-surround
    nvim-surround = {
      enable = true;
      settings = {__raw = "require('opts.nvim-surround')";};
    };
    # PART: flash
    flash = {
      enable = true;
      settings = {__raw = "require('opts.flash')";};
    };
    # PART: auto-save
    auto-save.enable = true;
    # PART: comment
    comment = {
      enable = true;
      settings = {
        pre_hook = "require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()";
      };
    };
    # PART: ts-context-commentstring
    ts-context-commentstring.enable = true;
    # PART: friendly-snippets
    friendly-snippets.enable = true;
    # PART: luasnip
    luasnip.enable = true;
    # PART: nvim-autopairs
    nvim-autopairs.enable = true;
    # PART: tmux-navigator
    tmux-navigator.enable = true;
    # PART: visual-multi
    visual-multi.enable = true;
    # PART: web-devicons
    web-devicons.enable = true;
    # PART: toggleterm
    toggleterm = {
      enable = true;
      settings = {__raw = "require('opts.toggleterm')";};
    };
    # PART: which-key
    which-key = {
      enable = true;
    };
    # PART: lualine
    lualine = {
      enable = true;
    };
    # PART: render-markdown
    render-markdown = {
      enable = true;
      settings = {__raw = "require('opts.render-markdown').opts";};
    };
    # PART: dashboard
    dashboard.enable = true;
    # PART: colorizer
    colorizer.enable = true;
    # PART: noice
    noice.enable = true;
    # PART: image
    image.enable = true;
    # PART: barbecue
    barbecue.enable = true;
    # PART: notify
    notify = {
      enable = true;
      luaConfig.post = ''
        local t = require('opts.nvim-notify')
        t.config(nil, t.opts)
      '';
      settings = {__raw = "require('opts.nvim-notify').opts";};
    };
    # PART: transparent
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
