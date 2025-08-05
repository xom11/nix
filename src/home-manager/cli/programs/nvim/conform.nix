{ ... }:

{
  programs.nixvim.plugins.conform-nvim = {
    enable = true;
    settings = {
      formatters_by_ft = {

        javascript =  [ "prettierd" ];
        typescript =  [ "prettierd" ];
        yaml =  [ "prettierd" ];
        json = [ "prettierd" ];
        markdown = [ "prettierd" ];
        scss = [ "prettierd" ];
        css = [ "prettierd" ];

        lua = [ "stylua" ];
        python = [ "isort" "black" ];
        rust = [ "rustfmt" ];
        sh = [ "shfmt" ];
        "_" = [ "trim_whitespace" ];
      };
    };
  };
}