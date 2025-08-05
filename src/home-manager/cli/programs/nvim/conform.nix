{ ... }:

{
  programs.nixvim.plugins.conform-nvim = {
    enable = true;
    settings.formatters_by_ft = {
      "*" = [ "codespell" ];
      "_" = [ "trim_whitespace" ];
      #go = [ "goimports" "golines" "gofmt" "gofumpt" ];
      javascript =  [ "prettierd" ];
      typescript =  [ "prettierd" ];
      yaml =  [ "prettierd" ];
      json = [ "jq" ];
      lua = [ "stylua" ];
      scss = [ "prettierd" ];
      css = [ "prettierd" ];
      python = [ "isort" "black" ];
      rust = [ "rustfmt" ];
      sh = [ "shfmt" ];
      #terraform = [ "terraform_fmt" ];
    };
  };
}