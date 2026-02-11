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
