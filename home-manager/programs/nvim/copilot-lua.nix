{ lib, config, ... }:
let
  cfg = config.modules.programs.nvim;
in
lib.mkIf cfg.enable
{
  programs.nixvim.plugins = {
    copilot-lua = {
      enable = true;
      settings = {
        panel = {
          enabled = true;
          auto_refresh = true;
        };
        suggestion = {
          enabled = true;
          auto_trigger = true;
          debounce = 75;
          keymap = {
            accept = "<Tab>";
          };
        };
      };
    };
  };
}