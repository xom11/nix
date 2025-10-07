{ lib, pkgs, config, ... }:
let
  cfg = config.modules.programs.nvim;
in
lib.mkIf cfg.enable
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
        nix = ["alejandra" ];

        lua = [ "stylua" ];
        python = [ "black" ];
        rust = [ "rustfmt" ];
        sh = [ "shfmt" ];
        "_" = [ "trim_whitespace" ];
      };
    };
  };
  home.packages = with pkgs; [
    black
    shfmt
    stylua
    alejandra
    prettierd
  ];
}
