{ lib, config, ... }:
let
  cfg = config.modules.programs.nvim;
in
lib.mkIf cfg.enable
{
  programs.nixvim.plugins = {
    copilot-lua = {
      enable = true;
    };
  };
}