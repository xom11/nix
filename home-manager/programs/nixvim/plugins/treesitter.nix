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
    extraPackages = with pkgs; [
      tree-sitter 
    ];
    plugins = {
      treesitter = {
        enable = true;
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
        #   html
        #   css
        #   javascript
        #   typescript
        #   tsx
        #   dockerfile
        # ];
        grammarPackages = pkgs.vimPlugins.nvim-treesitter.allGrammars;
        settings = {
          auto_install = false;
          highlight.enable = true;
          indent.enable = true;
        };
      };
    };
  };
}
