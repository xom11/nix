{ lib, config, ... }:
let
  cfg = config.modules.programs.nvim;
in
lib.mkIf cfg.enable
{
  programs.nixvim.plugins = {
    toggleterm = {
      enable = true;
      settings = {
        direction = "float";
        float_opts = {
          border = "curved";
          height = 30;
          width = 110;
        };
        open_mapping = "[[<a-t>]]";
      };
    };
  };
}
