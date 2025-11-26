{
  config,
  pkgs,
  ckModule,
  ...
}:
ckModule config ./.
{
  programs.nixvim = {
    filetype.extension.kbd = "lisp";
    plugins = {
      treesitter = {
        enable = true;
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          bash
          json
          lua
          markdown
          nix
          toml
          yaml
          python
          commonlisp
        ];
        settings = {
          auto_install = true;
          highlight.enable = true;
          indent.enable = true;
        };
      };
    };
  };
}
