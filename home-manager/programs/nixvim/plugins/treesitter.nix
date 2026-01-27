{
  config,
  pkgs,
  ckModule,
  ...
}:
ckModule config ./..
{
  programs.nixvim = {
    filetype.extension.kbd = "lisp";
    plugins = {
      treesitter = {
        enable = true;
        nixGrammars = true;
        grammarPackages = pkgs.vimPlugins.nvim-treesitter.allGrammars;
        extraPackages = with pkgs; [
          tree-sitter
        ];
        # grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        #   bash
        #   json
        #   lua
        #   markdown
        #   nix
        #   toml
        #   yaml
        #   python
        #   commonlisp
        #   powershell
        # html
        # css
        # javascript
        # typescript
        # tsx
        # dockerfile
        # query
        # ];
        settings = {
          auto_install = false;
          highlight.enable = true;
          indent.enable = true;
        };
      };
    };
  };
}
