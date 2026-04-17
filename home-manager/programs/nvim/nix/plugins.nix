# {
#   config,
#   ckModule,
#   pkgs,
#   ...
# }:
# ckModule config ./..
# {
#   programs.nixvim = {
#     plugins = {
#       copilot-lua.enable = true;
#       copilot-chat.enable = true;
#       img-clip.enable = true;
#       telescope = {
#         enable = true;
#         extensions = {
#           ui-select.enable = true;
#           frecency.enable = true;
#           fzf-native.enable = true;
#           file-browser.enable = true;
#         };
#       };
#       cmp-nvim-lsp.enable = true;
#       cmp-buffer.enable = true;
#       cmp-path.enable = true;
#       cmp-cmdline.enable = true;
#       cmp = {
#         enable = true;
#         autoEnableSources = true;
#       };
#       conform-nvim.enable = true;
#       treesitter = {
#         enable = true;
#         grammarPackages = pkgs.vimPlugins.nvim-treesitter.allGrammars;
#       };
#       treesitter-textobjects.enable = true;
#       vim-dadbod.enable = true;
#       vim-dadbod-ui.enable = true;
#       vim-dadbod-completion.enable = true;
#       gitsigns.enable = true;
#       neo-tree.enable = true;
#       todo-comments.enable = true;
#       harpoon.enable = true;
#       nvim-surround.enable = true;
#       flash.enable = true;
#       auto-save.enable = true;
#       comment = {
#         enable = true;
#         settings = {
#           pre_hook = "require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()";
#         };
#       };
#       ts-context-commentstring.enable = true;
#       friendly-snippets.enable = true;
#       luasnip.enable = true;
#       cmp_luasnip.enable = true;
#       nvim-autopairs.enable = true;
#       tmux-navigator.enable = true;
#       visual-multi.enable = true;
#       web-devicons.enable = true;
#       toggleterm.enable = true;
#       which-key.enable = true;
#       lualine.enable = true;
#       render-markdown.enable = true;
#       dashboard.enable = true;
#       colorizer.enable = true;
#       noice.enable = true;
#       image.enable = true;
#       barbecue.enable = true;
#       notify.enable = true;
#       transparent.enable = true;
#     };
#
#     # Auto-load all opts files after plugins
#     extraConfigLua = "require('plugins')";
#   };
#
#   home.packages = with pkgs; [
#     # conform formatters
#     black
#     shfmt
#     stylua
#     alejandra
#     prettierd
#     yamllint
#     yamlfmt
#     taplo
#
#     # lsp
#     nixd
#   ];
# }
